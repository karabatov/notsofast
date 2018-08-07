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
}

final class MealListViewModel<ConcreteProvider: DataProvider>: ProxyDataSource where ConcreteProvider.CellModel == Meal {
    typealias CellModel = MealCellModel
    private let dataProvider: ConcreteProvider

    init(dataProvider: ConcreteProvider) {
        self.dataProvider = dataProvider
    }

    // MARK: ProxyDataSource
    var dataSourceDelegate: ProxyDataSourceDelegate?

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

        return MealCellModel(meal: meal)
    }

    func titleForHeader(in section: Int) -> String? {
        return nil
    }
}
