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

enum EditMealCell {
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

    private var disposeBag = DisposeBag()

    required init() {
        configureDataOutput()
        configureInput()
    }

    private func configureDataOutput() {
        Observable.combineLatest(sizeSection, typeSection, dateSection, buttonSection) { ($0, $1, $2, $3) }
            .map { (sizes, types, dates, buttons) -> [EditMealSection] in
                return []
            }
            .bind(to: data)
            .disposed(by: disposeBag)
    }

    private func configureInput() {
        input
            .subscribe(
                onNext: { [weak self] input in
                    switch input {
                    case .configure(model: let newMeal, title: let newTitle):
                        self?.model.onNext(newMeal)
                        self?.title.onNext(newTitle.forDisplay())

                    case .selectedCell(_):
                        break
                    }
                },
                onError: nil,
                onCompleted: nil,
                onDisposed: nil
            )
            .disposed(by: disposeBag)
    }
}
