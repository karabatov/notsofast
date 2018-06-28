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
final class EditMealViewModel {
    let title = ReplaySubject<String>.create(bufferSize: 1)

    let input = PublishSubject<EditMealInput>()
    let output = PublishSubject<EditMealOutput>()

    let data = ReplaySubject<[EditMealSection]>.create(bufferSize: 1)
    private let sizeSection = PublishSubject<[EditMealCell]>()
    private let typeSection = PublishSubject<[EditMealCell]>()
    private let dateSection = PublishSubject<[EditMealCell]>()
    private let buttonSection = PublishSubject<[EditMealCell]>()

    private let model = PublishSubject<Meal>()

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
        configureModelSaving()
        // scheduleSectionUpdates()
    }

    private func configureSizeSection() {
        model
            .map { model -> [EditMealCell] in
                return [Serving.bite, Serving.handful, Serving.plate, Serving.bucket]
                    .map { size -> EditMealCell in
                        return EditMealCell.size(size: size, selected: size == model.size)
                    }
            }
            .distinctUntilChanged()
            .bind(to: sizeSection)
            .disposed(by: disposeBag)
    }

    private func configureTypeSection() {
        model
            .map { model -> [EditMealCell] in
                return [
                        Nutrients.fastCarb,
                        Nutrients.protein,
                        Nutrients.slowCarb,
                        Nutrients.fat
                    ]
                    .map { nutri -> EditMealCell in
                        return EditMealCell.ingredients(nutri: nutri, selected: model.nutri.contains(nutri))
                    }
            }
            .distinctUntilChanged()
            .bind(to: typeSection)
            .disposed(by: disposeBag)
    }

    private func configureDateSection() {
        model
            .map { model -> [EditMealCell] in
                return [
                    EditMealCell.date(model.eaten)
                ]
            }
            .distinctUntilChanged()
            .bind(to: dateSection)
            .disposed(by: disposeBag)
    }

    private func configureButtonsSection() {
        model
            .map { _ -> [EditMealCell] in
                return [
                    EditMealCell.delete
                ]
            }
            .distinctUntilChanged()
            .bind(to: buttonSection)
            .disposed(by: disposeBag)
    }

    private func scheduleSectionUpdates() {
        let sec0Bump = sizeSection
            .map { _ -> EditMealOutput in
                return EditMealOutput.reloadSection(0)
            }

        let sec1Bump = typeSection
            .map { _ -> EditMealOutput in
                return EditMealOutput.reloadSection(1)
            }

        let sec2Bump = dateSection
            .map { _ -> EditMealOutput in
                return EditMealOutput.reloadSection(2)
            }

        Observable.merge(sec0Bump, sec1Bump, sec2Bump)
            .bind(to: output)
            .disposed(by: disposeBag)
    }

    private func configureDataOutput() {
        Observable.combineLatest(sizeSection, typeSection, dateSection, buttonSection) { ($0, $1, $2, $3) }
            .map { (sizes, types, dates, buttons) -> [EditMealSection] in
                return [
                    EditMealSection(title: R.string.localizableStrings.serving(), rows: sizes),
                    EditMealSection(title: R.string.localizableStrings.nutrients(), rows: types),
                    EditMealSection(title: nil, rows: dates),
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
                case .configure(model: let newMeal, title: let newTitle):
                    self?.model.onNext(newMeal)
                    self?.title.onNext(newTitle.forDisplay())

                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(model, input) { ($0, $1) }
            .sample(input)
            .subscribe(onNext: { [weak self] model, input in
                switch input {
                case .selectedCell(let cell):
                    switch cell {
                    case .size(size: let size, selected: _):
                        self?.update(model: model, withSize: size)

                    case .ingredients(nutri: let nutri, selected: _):
                        self?.update(model: model, withNutri: nutri)

                    case .delete:
                        self?.delete()

                    default:
                        break
                    }

                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    private func configureModelSaving() {
        model
            .subscribe(onNext: { [weak self] mdl in
                self?.mealStorage.upsert(meal: mdl, original: mdl)
            })
            .disposed(by: disposeBag)
    }

    private func update(model: Meal, withSize size: Serving) {
        let newMeal = Meal(eaten: model.eaten, size: size, nutri: model.nutri, what: model.what)
        self.model.onNext(newMeal)
    }

    private func update(model: Meal, withNutri nutri: Nutrients) {
        var newNutri = model.nutri
        if newNutri.contains(nutri) {
            newNutri.subtract(nutri)
        } else {
            newNutri.insert(nutri)
        }
        let newMeal = Meal(eaten: model.eaten, size: model.size, nutri: newNutri, what: model.what)
        self.model.onNext(newMeal)
    }

    private func delete() {
        model
            .take(1)
            .do(onNext: { [weak self] mdl in
                self?.mealStorage.delete(meal: mdl)
            })
            .map { _ -> EditMealOutput in
                return EditMealOutput.dismissController
            }
            .bind(to: output)
            .disposed(by: disposeBag)
    }
}
