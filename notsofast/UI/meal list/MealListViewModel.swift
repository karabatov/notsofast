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

final class MealListViewModel: ProxyDataSource {

    // MARK: ProxyDataSource
    var dataSourceDelegate: ProxyDataSourceDelegate?

    func numberOfSections() -> Int {
        return 0
    }

    func numberOfItems(in section: Int) -> Int {
        return 0
    }

    func modelForItem(at indexPath: IndexPath) -> MealCellModel? {
        return nil
    }
}
