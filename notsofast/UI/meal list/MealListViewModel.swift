//
//  MealListViewModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 07/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxSwift

struct MealListDataConfig: Equatable {
    let startDate: Date
    let endDate: Date
}

struct MealListViewState: Equatable {
    let title: String
    let enableCalendarRightButton: Bool
    let listOfMealsHidden: Bool
    let emptyStateText: String
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

final class MealListViewModel<ConcreteProvider: DataProvider>: ViewModel, DataProvider where ConcreteProvider.CellModel == Meal, ConcreteProvider.DataConfig == MealListDataConfig {
    private let dataProvider: ConcreteProvider
    private let needToRefreshViewState = ReplaySubject<Void>.create(bufferSize: 1)
    private var disposeBag = DisposeBag()

    init(dataProvider: ConcreteProvider) {
        self.dataProvider = dataProvider

        needToRefreshViewState.onNext(())

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none

        let rdf = DateIntervalFormatter()
        rdf.dateTemplate = DateFormatter.dateFormat(fromTemplate: Constants.preferredDateTimeFormat, options: 0, locale: Locale.current)

        Observable.combineLatest(dataProvider.data, dataProvider.dataConfig, needToRefreshViewState) { ($0, $1, $2) }
            .map { data, dataConfig, _ -> MealListViewState in
                let emptyString: String
                if dataConfig.endDate == Date.distantFuture {
                    emptyString = R.string.localizableStrings.empty_state_present()
                } else {
                    emptyString = R.string.localizableStrings.empty_state_past()
                }

                if dataConfig.endDate > Date() {
                    return MealListViewState(
                        title: rdf.string(from: dataConfig.startDate, to: dataConfig.startDate + 24 * 60 * 60),
                        enableCalendarRightButton: false,
                        listOfMealsHidden: data.isEmpty,
                        emptyStateText: emptyString
                    )
                } else {
                    return MealListViewState(
                        title: df.string(from: dataConfig.startDate),
                        enableCalendarRightButton: true,
                        listOfMealsHidden: data.isEmpty,
                        emptyStateText: emptyString
                    )
                }
            }
            .distinctUntilChanged()
            .bind(to: viewState)
            .disposed(by: disposeBag)

        let dcInput = Observable.combineLatest(dataProvider.dataConfig, input) { ($0, $1) }

        input
            .filter { input in
                switch input {
                case .goLeft, .goRight:
                    return true

                default:
                    return false
                }
            }
            .withLatestFrom(dcInput)
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
            .subscribe(onNext: { newDC in
                dataProvider.dataConfig.onNext(newDC)
            })
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

    // MARK: DataProvider

    let dataConfig = ReplaySubject<MealListDataConfig>.create(bufferSize: 1)
    let data = ReplaySubject<[DataSourceSection<MealCellModel>]>.create(bufferSize: 1)

    // MARK: ProxyDataSource

    private weak var dataSourceDelegate: ProxyDataSourceDelegate?

    func configure(delegate: ProxyDataSourceDelegate?) {
        dataSourceDelegate = delegate
    }

    func isEmpty() -> Bool {
        return dataProvider.isEmpty()
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

    // MARK: Helpers

    private func openEditMeal(from item: IndexPath) {
        data
            .take(1)
            .map { sections -> Meal? in
                return sections[safeIndex: item.section]?.items[safeIndex: item.row]
            }
            .filter { $0 != nil }
            .map { MealListOutput.openEditMeal(meal: $0!) }
            .debug("openEditMeal")
            // TODO: Check that it doesn't send completion.
            .bind(to: output)
            .disposed(by: disposeBag)
    }
}
