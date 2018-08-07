//
//  MealListDataProvider.swift
//  notsofast
//
//  Created by Yuri Karabatov on 07/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import CoreData

struct MealListDataConfig {
    let startDate: Date
    let endDate: Date
}

final class MealListDataProvider: DataProvider {
    private var frc: NSFetchedResultsController<MealEntity>

    init(frc: NSFetchedResultsController<MealEntity>, config: MealListDataConfig) {
        self.config = config
        self.frc = frc
    }

    // MARK: DataProvider

    typealias DataConfig = MealListDataConfig
    var config: MealListDataConfig

    // MARK: ProxyDataSource

    private weak var dataSourceDelegate: ProxyDataSourceDelegate?

    typealias CellModel = Meal

    func configure(delegate: ProxyDataSourceDelegate?) {
        dataSourceDelegate = delegate
    }

    func numberOfSections() -> Int {
        return frc.sections?.count ?? 0
    }

    func numberOfItems(in section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }

    func modelForItem(at indexPath: IndexPath) -> Meal? {
        return frc.object(at: indexPath).meal()
    }

    func titleForHeader(in section: Int) -> String? {
        return nil
    }
}
