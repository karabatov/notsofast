//
//  MealWheelModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 17/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import CoreData

enum DataSourceChange {
    case insert(IndexPath)
    case delete(IndexPath)
    case update(IndexPath)
}

/// Represents the logical data source for the meal wheel.
protocol MealWheelDataModel {
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func model(forItemAt indexPath: IndexPath) -> Meal?

    func configure(delegate: MealWheelDataModelDelegate?)
}

/// Delegate for the meal wheel data source.
protocol MealWheelDataModelDelegate {
    /// Batch-apply an ordered set of data source changes.
    func batch(changes: [DataSourceChange])
}

/// Actual class to provide data to the meal wheel.
final class MealWheelLiveModel: NSObject, MealWheelDataModel, NSFetchedResultsControllerDelegate {
    private let frc: NSFetchedResultsController<MealEntity>

    init(frc: NSFetchedResultsController<MealEntity>) {
        self.frc = frc
        super.init()
        frc.delegate = self
    }

    // MARK: MealWheelDataModel

    private var delegate: MealWheelDataModelDelegate?

    func numberOfSections() -> Int {
        return frc.sections?.count ?? 0
    }

    func numberOfItems(in section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }

    func model(forItemAt indexPath: IndexPath) -> Meal? {
        return frc.object(at: indexPath).meal()
    }

    func configure(delegate: MealWheelDataModelDelegate?) {
        self.delegate = delegate
    }

    // MARK: NSFetchedResultsControllerDelegate
    private var changeCollector = [DataSourceChange]()

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIP = newIndexPath {
                changeCollector.append(DataSourceChange.insert(newIP))
            }

        case .delete:
            if let delIP = indexPath {
                changeCollector.append(DataSourceChange.delete(delIP))
            }

        case .update:
            if let updIP = indexPath {
                changeCollector.append(DataSourceChange.update(updIP))
            }

        case .move:
            if let delIP = indexPath, let newIP = newIndexPath {
                changeCollector.append(DataSourceChange.delete(delIP))
                changeCollector.append(DataSourceChange.insert(newIP))
            }
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Optimistically preserve capacity for future changes.
        changeCollector.removeAll(keepingCapacity: true)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NSFLog("Batch! Collector: \(changeCollector.count)")
        delegate?.batch(changes: changeCollector)
    }
}
