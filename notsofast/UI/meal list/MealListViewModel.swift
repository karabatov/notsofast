//
//  MealListViewModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 07/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxSwift

struct MealListViewState: Equatable {
    let title: String
    let enableCalendarRightButton: Bool
}

enum MealListInput {
    case goLeft
    case goRight
    case itemSelected(IndexPath)
}

enum MealListOutput {
    case openEditMeal(meal: Meal)
}

struct MealCellModel {
    let meal: Meal
    let size: String
    let date: Date
    let displayElapsedTime: Bool
    let nutrients: Nutrients
}

final class MealListViewModel<ConcreteProvider: DataProvider>: ProxyDataSource, ProxyDataSourceDelegate, ViewModel where ConcreteProvider.CellModel == Meal, ConcreteProvider.DataConfig == MealListDataConfig {
    typealias CellModel = MealCellModel
    private let dataProvider: ConcreteProvider
    private var disposeBag = DisposeBag()

    init(dataProvider: ConcreteProvider) {
        self.dataProvider = dataProvider
        self.dataProvider.configure(delegate: self)

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none

        let rdf = DateIntervalFormatter()
        rdf.dateStyle = .short
        rdf.timeStyle = .short

        dataProvider.dataConfig
            .map { dataConfig -> MealListViewState in
                if dataConfig.endDate > Date() {
                    return MealListViewState(
                        title: rdf.string(from: dataConfig.startDate, to: dataConfig.startDate + 24 * 60 * 60),
                        enableCalendarRightButton: false
                    )
                } else {
                    return MealListViewState(
                        title: df.string(from: dataConfig.startDate),
                        enableCalendarRightButton: true
                    )
                }
            }
            .bind(to: viewState)
            .disposed(by: disposeBag)

        Observable.combineLatest(dataProvider.dataConfig, input) { ($0, $1) }
            .sample(input)
            .filter { _, input in
                switch input {
                case .goLeft, .goRight:
                    return true

                default:
                    return false
                }
            }
            .map { dataConfig, input -> MealListDataConfig in
                let newStartDate: Date
                let newEndDate: Date

                let now = Date()

                switch input {
                case .goLeft where dataConfig.endDate >= now:
                    newEndDate = now.beginningOfDay()
                    newStartDate = newEndDate.addingTimeInterval(-Date.sutki())

                case .goLeft where dataConfig.endDate < now:
                    newStartDate = dataConfig.startDate.beginningOfDay().addingTimeInterval(-Date.sutki())
                    newEndDate = newStartDate.addingTimeInterval(Date.sutki())

                case .goRight:
                    let end = dataConfig.endDate.beginningOfDay().addingTimeInterval(Date.sutki())
                    if end > now {
                        newEndDate = Date.distantFuture
                        newStartDate = now.beginningOfNextHourYesterday()
                    } else {
                        newStartDate = dataConfig.endDate.beginningOfDay()
                        newEndDate = newStartDate.addingTimeInterval(Date.sutki())
                    }

                default:
                    fatalError("Impossible date configuration when switching day.")
                }

                return MealListDataConfig(startDate: newStartDate, endDate: newEndDate)
            }
            .bind(to: dataProvider.dataConfig)
            .disposed(by: disposeBag)

        input
            .subscribe(onNext: { [weak self] inputItem in
                switch inputItem {
                case .itemSelected(let item):
                    self?.openEditMeal(from: item)

                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: ViewModel

    let viewState = ReplaySubject<MealListViewState>.create(bufferSize: 1)
    let input = PublishSubject<MealListInput>()
    let output = PublishSubject<MealListOutput>()

    // MARK: ProxyDataSource

    private weak var dataSourceDelegate: ProxyDataSourceDelegate?

    func configure(delegate: ProxyDataSourceDelegate?) {
        dataSourceDelegate = delegate
    }

    func numberOfSections() -> Int {
        return dataProvider.numberOfSections()
    }

    func numberOfItems(in section: Int) -> Int {
        return dataProvider.numberOfItems(in: section)
    }

    func modelForItem(at indexPath: IndexPath) -> MealCellModel? {
        guard let meal = dataProvider.modelForItem(at: indexPath) else {
            return nil
        }

        return MealCellModel(
            meal: meal,
            size: meal.size.forDisplay(),
            date: meal.eaten,
            displayElapsedTime: Date().timeIntervalSince(meal.eaten) <= 24 * 60 * 60,
            nutrients: meal.nutri
        )
    }

    func titleForHeader(in section: Int) -> String? {
        return dataProvider.titleForHeader(in: section)
    }

    // MARK: ProxyDataSourceDelegate

    func batch(changes: [ProxyDataSourceChange]) {
        dataSourceDelegate?.batch(changes: changes)
    }

    func forceReload() {
        dataSourceDelegate?.forceReload()
    }

    // MARK: Helpers

    private func openEditMeal(from item: IndexPath) {
        guard let meal = dataProvider.modelForItem(at: item) else {
            return
        }

        output.onNext(MealListOutput.openEditMeal(meal: meal))
    }
}
