//
//  EditMealViewModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 26/06/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxSwift

struct EditMealSection: Equatable {
    let title: String?
    let rows: [EditMealCell]
}

enum EditMealCell: Equatable {
    case size(size: Serving, selected: Bool)
    case ingredients(nutri: Nutrients)
    case date(Date)
    case editDate(Date)
    case delete
}

struct EditMealViewState: Equatable {
    let title: String
    let hidesCancelButton: Bool
}

struct EditMealDataConfig: Equatable {
    let meal: Meal
    let editingDate: Bool
}

enum EditMealDataConfigIntention {
    case meal(Meal)
    case editingDate(Bool)
}

/// Title of the Create/Edit meal controller (it doesn't care too much).
enum CreateEditMealTitle {
    case create
    case edit

    func forDisplay() -> String {
        switch self {
        case .create:
            return R.string.localizableStrings.create_meal()

        case .edit:
            return R.string.localizableStrings.edit_meal()
        }
    }
}

/// Input actions for the view model.
enum EditMealInput {
    case selectedCellAt(IndexPath)
    case doneTapped
    case cancelTapped
    case deleteConfirmed
    case selectedDate(Date)
    case selectedNutrients(Nutrients)
}

enum EditMealOutput {
    case dismissController
    case confirmDeletion
    case scrollToRowAfterUpdates(IndexPath)
}

/// View model for the create/edit meal view controller.
final class EditMealViewModel: ViewModel, DataProvider {
    private let sizeSection = PublishSubject<[EditMealCell]>()
    private let typeSection = PublishSubject<[EditMealCell]>()
    private let dateSection = PublishSubject<[EditMealCell]>()
    private let buttonSection = PublishSubject<[EditMealCell]>()
    private let data = ReplaySubject<[EditMealSection]>.create(bufferSize: 1)
    private var dsSections: [EditMealSection] = []

    private let mealStorage: MealActionController

    private var disposeBag = DisposeBag()

    required init(mealStorage: MealActionController) {
        self.mealStorage = mealStorage

        configureViewState()
        configureSizeSection()
        configureTypeSection()
        configureDateSection()
        configureButtonsSection()
        configureDataOutput()
        configureInput()
        configureConfigIntention()
    }

    // MARK: ViewModel

    let viewState = ReplaySubject<EditMealViewState>.create(bufferSize: 1)
    let input = PublishSubject<EditMealInput>()
    let output = PublishSubject<EditMealOutput>()

    // MARK: DataProvider

    typealias DataConfig = EditMealDataConfig
    let dataConfig = ReplaySubject<EditMealDataConfig>.create(bufferSize: 1)
    private let dataConfigIntention = PublishSubject<EditMealDataConfigIntention>()

    // MARK: ProxyDataSource

    typealias CellModel = EditMealCell
    weak var dataSourceDelegate: ProxyDataSourceDelegate?

    func isEmpty() -> Bool {
        return false
    }

    func numberOfSections() -> Int {
        return dsSections.count
    }

    func numberOfItems(in section: Int) -> Int {
        return dsSections[section].rows.count
    }

    func titleForHeader(in section: Int) -> String? {
        return dsSections[section].title
    }

    func modelForItem(at indexPath: IndexPath) -> EditMealCell? {
        return dsSections[indexPath.section].rows[indexPath.row]
    }

    func configure(delegate: ProxyDataSourceDelegate?) {
        dataSourceDelegate = delegate
    }

    // MARK: Helpers

    private func configureViewState() {
        dataConfig
            .map { config -> EditMealViewState in
                if config.meal.id == nil {
                    return EditMealViewState(
                        title: CreateEditMealTitle.create.forDisplay(),
                        hidesCancelButton: false
                    )
                } else {
                    return EditMealViewState(
                        title: CreateEditMealTitle.edit.forDisplay(),
                        hidesCancelButton: true
                    )
                }
            }
            .bind(to: viewState)
            .disposed(by: disposeBag)
    }

    private func configureSizeSection() {
        dataConfig
            .map { config -> [EditMealCell] in
                return [Serving.bite, Serving.handful, Serving.plate, Serving.bucket]
                    .map { size -> EditMealCell in
                        return EditMealCell.size(size: size, selected: size == config.meal.size)
                    }
            }
            .distinctUntilChanged()
            .bind(to: sizeSection)
            .disposed(by: disposeBag)
    }

    private func configureTypeSection() {
        dataConfig
            .map { config -> [EditMealCell] in
                return [
                    EditMealCell.ingredients(nutri: config.meal.nutri)
                ]
            }
            .distinctUntilChanged()
            .bind(to: typeSection)
            .disposed(by: disposeBag)
    }

    private func configureDateSection() {
        dataConfig
            .map { config -> [EditMealCell] in
                if config.editingDate {
                    return [
                        EditMealCell.editDate(config.meal.eaten)
                    ]
                } else {
                    return [
                        EditMealCell.date(config.meal.eaten)
                    ]
                }
            }
            .distinctUntilChanged()
            .bind(to: dateSection)
            .disposed(by: disposeBag)
    }

    private func configureButtonsSection() {
        dataConfig
            .map { config -> [EditMealCell] in
                if config.meal.id != nil {
                    return [
                        EditMealCell.delete
                    ]
                } else {
                    return []
                }
            }
            .distinctUntilChanged()
            .bind(to: buttonSection)
            .disposed(by: disposeBag)
    }

    private func configureDataOutput() {
        Observable.combineLatest(sizeSection, typeSection, dateSection, buttonSection) { ($0, $1, $2, $3) }
            .map { (sizes, types, dates, buttons) -> [EditMealSection] in
                var sections = [
                    EditMealSection(title: R.string.localizableStrings.serving(), rows: sizes),
                    EditMealSection(title: R.string.localizableStrings.nutrients(), rows: types),
                    EditMealSection(title: R.string.localizableStrings.edit_meal_date(), rows: dates),
                ]

                if buttons.count > 0 {
                    sections.append(EditMealSection(title: nil, rows: buttons))
                }

                return sections
            }
            .distinctUntilChanged()
            .do(onNext: { [weak self] sections in
                self?.dsSections = sections
            })
            .scan([EditMealSection]()) { [weak self] (dataBefore, newData) -> [EditMealSection] in
                var changes: [ProxyDataSourceChange] = []

                var sectionIndex = 0
                for (lhs, rhs) in zip(dataBefore, newData) {
                    var rowIndex = 0
                    for (lhr, rhr) in zip(lhs.rows, rhs.rows) {
                        if lhr != rhr {
                            changes.append(ProxyDataSourceChange.update(IndexPath(row: rowIndex, section: sectionIndex)))
                        }

                        rowIndex += 1
                    }

                    if rhs.rows.count > lhs.rows.count {
                        for i in lhs.rows.count..<rhs.rows.count {
                            changes.append(ProxyDataSourceChange.insert(IndexPath(row: i, section: sectionIndex)))
                        }
                    } else if rhs.rows.count < lhs.rows.count {
                        for i in rhs.rows.count..<lhs.rows.count {
                            changes.append(ProxyDataSourceChange.delete(IndexPath(row: i, section: sectionIndex)))
                        }
                    }

                    sectionIndex += 1
                }
                if newData.count > dataBefore.count {
                    for i in dataBefore.count..<newData.count {
                        changes.append(ProxyDataSourceChange.insertSection(i))
                    }
                } else if newData.count < dataBefore.count {
                    for i in newData.count..<dataBefore.count {
                        changes.append(ProxyDataSourceChange.deleteSection(i))
                    }
                }

                self?.dataSourceDelegate?.batch(changes: changes)

                return newData
            }
            .bind(to: data)
            .disposed(by: disposeBag)
    }

    private func configureInput() {
        Observable.combineLatest(dataConfig, data, input) { ($0, $1, $2) }
            .sample(input)
            .subscribe(onNext: { [weak self] config, data, input in
                switch input {
                case .selectedCellAt(let indexPath):
                    let cell = data[indexPath.section].rows[indexPath.row]
                    switch cell {
                    case .size(size: let size, selected: _):
                        self?.update(model: config.meal, withSize: size)

                    case .delete:
                        self?.output.onNext(EditMealOutput.confirmDeletion)

                    case .date(_):
                        self?.output.onNext(EditMealOutput.scrollToRowAfterUpdates(indexPath))
                        self?.dataConfigIntention.onNext(EditMealDataConfigIntention.editingDate(true))

                    default:
                        break
                    }

                case .doneTapped:
                    if let savedMeal = self?.mealStorage.upsert(meal: config.meal) {
                        self?.dataConfigIntention.onNext(EditMealDataConfigIntention.meal(savedMeal))
                    }
                    self?.output.onNext(EditMealOutput.dismissController)

                case .cancelTapped:
                    self?.output.onNext(EditMealOutput.dismissController)

                case .deleteConfirmed:
                    self?.mealStorage.delete(meal: config.meal)
                    self?.output.onNext(EditMealOutput.dismissController)

                case .selectedDate(let date):
                    self?.update(model: config.meal, withDate: date)

                case .selectedNutrients(let nutri):
                    self?.update(model: config.meal, withNutrients: nutri)
                }
            })
            .disposed(by: disposeBag)
    }

    private func configureConfigIntention() {
        Observable.combineLatest(dataConfig, dataConfigIntention) { ($0, $1) }
            .sample(dataConfigIntention)
            .map { (config, intention) -> EditMealDataConfig in
                switch intention {
                case .meal(let meal):
                    return EditMealDataConfig(meal: meal, editingDate: config.editingDate)

                case .editingDate(let editing):
                    return EditMealDataConfig(meal: config.meal, editingDate: editing)
                }
            }
            .bind(to: dataConfig)
            .disposed(by: disposeBag)
    }

    private func update(model: Meal, withDate date: Date) {
        let newMeal = Meal(id: model.id, eaten: date, size: model.size, nutri: model.nutri, what: model.what)
        dataConfigIntention.onNext(EditMealDataConfigIntention.meal(newMeal))
    }

    private func update(model: Meal, withNutrients nutrients: Nutrients) {
        let newMeal = Meal(id: model.id, eaten: model.eaten, size: model.size, nutri: nutrients, what: model.what)
        dataConfigIntention.onNext(EditMealDataConfigIntention.meal(newMeal))
    }

    private func update(model: Meal, withSize size: Serving) {
        let newMeal = Meal(id: model.id, eaten: model.eaten, size: size, nutri: model.nutri, what: model.what)
        dataConfigIntention.onNext(EditMealDataConfigIntention.meal(newMeal))
    }
}
