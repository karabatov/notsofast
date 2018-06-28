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
    func titleForHeader(in section: Int) -> String?
    func model(forItemAt indexPath: IndexPath) -> Meal?

    func configure(delegate: MealWheelDataModelDelegate?)
}

/// Delegate for the meal wheel data source.
protocol MealWheelDataModelDelegate {
    /// Batch-apply an ordered set of data source changes.
    func batch(changes: [DataSourceChange])
    /// Just force-reload the target.
    func forceReload()
}

/// Actual class to provide data to the meal wheel.
final class MealWheelLiveModel: NSObject, MealWheelDataModel, NSFetchedResultsControllerDelegate {
    private let frc: NSFetchedResultsController<MealEntity>
    private let dateFormatter = DateFormatter()

    init(frc: NSFetchedResultsController<MealEntity>) {
        self.frc = frc
        super.init()
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            fatalError("Failed to fetch! No live updates!")
        }

        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }

    // MARK: MealWheelDataModel

    private var delegate: MealWheelDataModelDelegate?

    func numberOfSections() -> Int {
        return frc.sections?.count ?? 0
    }

    func numberOfItems(in section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }

    func titleForHeader(in section: Int) -> String? {
        guard
            let name = frc.sections?[section].name,
            let interval = Double(name)
        else {
            return "SHIT"
        }

        let date = Date(timeIntervalSince1970: interval)
        return dateFormatter.string(from: date)
    }

    func model(forItemAt indexPath: IndexPath) -> Meal? {
        return frc.object(at: indexPath).meal()
    }

    func configure(delegate: MealWheelDataModelDelegate?) {
        self.delegate = delegate
    }

    // MARK: NSFetchedResultsControllerDelegate
    private var changeCollector = [DataSourceChange]()
    private var sectionsCounter = 0

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
        sectionsCounter = numberOfSections()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard sectionsCounter == numberOfSections() else {
            sectionsCounter = numberOfSections()
            delegate?.forceReload()
            return
        }
        delegate?.batch(changes: changeCollector)
    }
}
