//
//  MealListViewModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 07/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation

struct MealCellModel {
    let meal: Meal
    let size: String
    let absoluteDate: String
    let relativeDate: String
    let nutrients: Nutrients
}

/// TODO: Make some kind of ViewModel protocol + merge it with ProxyDataSource.
final class MealListViewModel<ConcreteProvider: DataProvider>: ProxyDataSource, ProxyDataSourceDelegate where ConcreteProvider.CellModel == Meal, ConcreteProvider.DataConfig == MealListDataConfig {
    typealias CellModel = MealCellModel
    private let dataProvider: ConcreteProvider
    private var agoDateFormatter: DateComponentsFormatter = {
        let df = DateComponentsFormatter()

        df.maximumUnitCount = 1
        df.unitsStyle = .abbreviated
        df.allowedUnits = [.hour, .minute]

        return df
    }()
    private var absDateFormatter: DateFormatter = {
        let df = DateFormatter()

        df.dateStyle = .medium
        df.timeStyle = .short

        return df
    }()

    init(dataProvider: ConcreteProvider) {
        self.dataProvider = dataProvider
        self.dataProvider.configure(delegate: self)
    }

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

        let ago = Date().timeIntervalSince(meal.eaten)
        let agoStr: String
        // Only display “… ago” if no more than 24 hours have passed.
        if let formStr = agoDateFormatter.string(from: ago), ago <= 24 * 60 * 60 {
            agoStr = formStr
        } else {
            agoStr = ""
        }

        return MealCellModel(
            meal: meal,
            size: meal.size.forDisplay(),
            absoluteDate: absDateFormatter.string(from: meal.eaten),
            relativeDate: agoStr,
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
}
