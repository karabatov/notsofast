//
//  EditMealViewModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 26/06/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxSwift

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

    let dataConfig = ReplaySubject<EditMealDataConfig>.create(bufferSize: 1)
    private let dataConfigIntention = PublishSubject<EditMealDataConfigIntention>()
    let data = ReplaySubject<[DataSourceSection<EditMealCell>]>.create(bufferSize: 1)

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
            .map { (sizes, types, dates, buttons) -> [DataSourceSection<EditMealCell>] in
                var sections = [
                    DataSourceSection<EditMealCell>(name: R.string.localizableStrings.serving(), items: sizes),
                    DataSourceSection<EditMealCell>(name: R.string.localizableStrings.nutrients(), items: types),
                    DataSourceSection<EditMealCell>(name: R.string.localizableStrings.edit_meal_date(), items: dates)
                ]

                if buttons.count > 0 {
                    sections.append(DataSourceSection<EditMealCell>(name: nil, items: buttons))
                }

                return sections
            }
            .distinctUntilChanged()
            .bind(to: data)
            .disposed(by: disposeBag)
    }

    private func configureInput() {
        Observable.combineLatest(dataConfig, data, input) { ($0, $1, $2) }
            .sample(input)
            .subscribe(onNext: { [weak self] config, data, input in
                switch input {
                case .selectedCellAt(let indexPath):
                    let cell = data[indexPath.section].items[indexPath.row]
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
