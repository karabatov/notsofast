//
//  MealWheelModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 17/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import CoreData

/// Represents the logical data source for the meal wheel.
protocol MealWheelDataModel {
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func model(forItemAt indexPath: IndexPath) -> Meal?
}

/// Actual class to provide data to the meal wheel.
final class MealWheelLiveModel: NSObject {
    private let frc: NSFetchedResultsController<MealEntity>

    init(frc: NSFetchedResultsController<MealEntity>) {
        self.frc = frc
    }
}

extension MealWheelLiveModel: MealWheelDataModel {
    func numberOfSections() -> Int {
        return frc.sections?.count ?? 0
    }

    func numberOfItems(in section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }

    func model(forItemAt indexPath: IndexPath) -> Meal? {
        return frc.object(at: indexPath).meal()
    }
}

extension MealWheelLiveModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // Do nothing.
    }
}
