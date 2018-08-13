//
//  EditMealViewModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 26/06/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxSwift

struct EditMealSection {
    let title: String?
    let rows: [EditMealCell]
}

enum EditMealCell: Equatable {
    case size(size: Serving, selected: Bool)
    case ingredients(nutri: Nutrients, selected: Bool)
    case date(Date)
    case delete
}

struct EditMealViewState: Equatable {
    let title: String
    let displaysCancelButton: Bool
}

struct EditMealDataConfig: Equatable {
    let meal: Meal
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
    case configure(model: Meal, title: CreateEditMealTitle)
    case selectedCell(EditMealCell)
}

enum EditMealOutput {
    case reloadSection(Int)
    case dismissController
}

/// View model for the create/edit meal view controller.
final class EditMealViewModel: ViewModel, DataProvider {
    private let sizeSection = PublishSubject<[EditMealCell]>()
    private let typeSection = PublishSubject<[EditMealCell]>()
    private let dateSection = PublishSubject<[EditMealCell]>()
    private let buttonSection = PublishSubject<[EditMealCell]>()
    private let data = ReplaySubject<[EditMealSection]>.create(bufferSize: 1)

    private let mealStorage: MealActionController

    private var disposeBag = DisposeBag()

    required init(mealStorage: MealActionController) {
        self.mealStorage = mealStorage

        configureSizeSection()
        configureTypeSection()
        configureDateSection()
        configureButtonsSection()
        configureDataOutput()
        configureInput()
    }

    // MARK: ViewModel

    let viewState = ReplaySubject<EditMealViewState>.create(bufferSize: 1)
    let input = PublishSubject<EditMealInput>()
    let output = PublishSubject<EditMealOutput>()

    // MARK: DataProvider

    typealias DataConfig = EditMealDataConfig
    let dataConfig = ReplaySubject<EditMealDataConfig>.create(bufferSize: 1)

    // MARK: ProxyDataSource

    typealias CellModel = EditMealCell
    weak var dataSourceDelegate: ProxyDataSourceDelegate?

    func numberOfSections() -> Int {
        return 3
    }

    func numberOfItems(in section: Int) -> Int {
        switch section {
        default:
            return 0
        }
    }

    func titleForHeader(in section: Int) -> String? {
        return ""
    }

    func modelForItem(at indexPath: IndexPath) -> EditMealCell? {
        return nil
    }

    func configure(delegate: ProxyDataSourceDelegate?) {
        dataSourceDelegate = delegate
    }

    // MARK: Helpers

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
                        Nutrients.fastCarb,
                        Nutrients.protein,
                        Nutrients.slowCarb,
                        Nutrients.fat
                    ]
                    .map { nutri -> EditMealCell in
                        return EditMealCell.ingredients(nutri: nutri, selected: config.meal.nutri.contains(nutri))
                    }
            }
            .distinctUntilChanged()
            .bind(to: typeSection)
            .disposed(by: disposeBag)
    }

    private func configureDateSection() {
        dataConfig
            .map { config -> [EditMealCell] in
                return [
                    EditMealCell.date(config.meal.eaten)
                ]
            }
            .distinctUntilChanged()
            .bind(to: dateSection)
            .disposed(by: disposeBag)
    }

    private func configureButtonsSection() {
        dataConfig
            .map { _ -> [EditMealCell] in
                return [
                    EditMealCell.delete
                ]
            }
            .distinctUntilChanged()
            .bind(to: buttonSection)
            .disposed(by: disposeBag)
    }

    private func configureDataOutput() {
        Observable.combineLatest(sizeSection, typeSection, dateSection, buttonSection) { ($0, $1, $2, $3) }
            .map { (sizes, types, dates, buttons) -> [EditMealSection] in
                return [
                    EditMealSection(title: R.string.localizableStrings.serving(), rows: sizes),
                    EditMealSection(title: R.string.localizableStrings.nutrients(), rows: types),
                    EditMealSection(title: R.string.localizableStrings.edit_meal_date(), rows: dates),
                    EditMealSection(title: nil, rows: buttons),
                ]
            }
            .bind(to: data)
            .disposed(by: disposeBag)
    }

    private func configureInput() {
        input
            .subscribe(onNext: { [weak self] input in
                switch input {
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(dataConfig, input) { ($0, $1) }
            .sample(input)
            .subscribe(onNext: { [weak self] config, input in
                switch input {
                case .selectedCell(let cell):
                    switch cell {
                    case .size(size: let size, selected: _):
                        self?.update(model: config.meal, withSize: size)

                    case .ingredients(nutri: let nutri, selected: _):
                        self?.update(model: config.meal, withNutri: nutri)

                    case .delete:
                        self?.delete(model: config.meal)

                    default:
                        break
                    }

                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    private func update(model: Meal, withSize size: Serving) {
        let newMeal = Meal(id: model.id, eaten: model.eaten, size: size, nutri: model.nutri, what: model.what)
        dataConfig.onNext(EditMealDataConfig(meal: newMeal))
    }

    private func update(model: Meal, withNutri nutri: Nutrients) {
        var newNutri = model.nutri
        if newNutri.contains(nutri) {
            newNutri.subtract(nutri)
        } else {
            newNutri.insert(nutri)
        }
        let newMeal = Meal(id: model.id, eaten: model.eaten, size: model.size, nutri: newNutri, what: model.what)
        dataConfig.onNext(EditMealDataConfig(meal: newMeal))
    }

    private func delete(model: Meal) {
        mealStorage.delete(meal: model)
        output.onNext(EditMealOutput.dismissController)
    }
}
