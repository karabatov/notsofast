//
//  CoreDataProvider.swift
//  notsofast
//
//  Created by Yuri Karabatov on 25/06/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import CoreData

/// Types of places we need to have requests for.
enum FetchResultsTarget {
    /// List of meals for the last twenty four hours.
    case twentyFourHourList
    /// Last logged meal.
    case lastRecordedMeal
}

protocol MealActionController {
    func upsert(meal: Meal) -> Meal
    func delete(meal: Meal)
}

/// Maintains a Core Data stack and returns preconfigured results controllers.
final class CoreDataProvider: MealActionController {
    static var sharedInstance = CoreDataProvider()

    private let container: NSPersistentContainer

    required init() {
        container = NSPersistentContainer(name: "MealsModel")
        container.loadPersistentStores() { description, maybeError in
            if let error = maybeError {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }

    func dataProviderForMealList(config: MealListDataConfig) -> FRCDataProvider<MealEntity, MealListDataSection, MealListDataConfig> {
        let fr = NSFetchRequest<MealEntity>(entityName: "MealEntity")
        fr.predicate = NSPredicate(format: "eaten >= %@ and eaten <= %@", argumentArray: [config.startDate, config.endDate])
        fr.sortDescriptors = [NSSortDescriptor(key: "eaten", ascending: false)]
        let frc = NSFetchedResultsController(
            fetchRequest: fr,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: "sectionName",
            cacheName: "MealList"
        )
        try? frc.performFetch()
        return FRCDataProvider.init(
            frc: frc,
            config: config,
            applyDataConfigChange: { dc, frc in
                frc.fetchRequest.predicate = NSPredicate(format: "eaten >= %@ and eaten <= %@", argumentArray: [dc.startDate, dc.endDate])
            },
            itemToCellModel: { entity -> Meal? in
                return entity.meal()
            }
        )
    }

    /// Returns a preconfigured fetched results controller for the target place to be used.
    func fetchedResultsController(for target: FetchResultsTarget) -> NSFetchedResultsController<MealEntity> {
        switch target {
        case .twentyFourHourList:
            let fr = NSFetchRequest<MealEntity>(entityName: "MealEntity")
            /// Limit the list to the last 24 hours only.
            fr.predicate = NSPredicate(format: "eaten >= %@", argumentArray: [Date.init(timeIntervalSinceNow: -60.0 * 60.0 * 24.0)])
            fr.sortDescriptors = [NSSortDescriptor(key: "eaten", ascending: true)]
            let frc = NSFetchedResultsController(
                fetchRequest: fr,
                managedObjectContext: container.viewContext,
                sectionNameKeyPath: "sectionName",
                cacheName: nil
            )
            try? frc.performFetch()
            return frc

        case .lastRecordedMeal:
            let fr = NSFetchRequest<MealEntity>(entityName: "MealEntity")
            fr.sortDescriptors = [NSSortDescriptor(key: "eaten", ascending: false)]
            fr.fetchLimit = 1
            let frc = NSFetchedResultsController(
                fetchRequest: fr,
                managedObjectContext: container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            try? frc.performFetch()
            return frc
        }
    }

    private func entity(from meal: Meal) -> MealEntity? {
        guard
            let obURI = meal.id,
            let obID = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: obURI)
        else {
            return nil
        }

        return container.viewContext.object(with: obID) as? MealEntity
    }

    // MARK: MealActionController

    func upsert(meal: Meal) -> Meal {
        let context = container.viewContext

        let editEntity: MealEntity
        if let existing = entity(from: meal) {
            editEntity = existing
        } else {
            editEntity = MealEntity(entity: MealEntity.entity(), insertInto: context)
        }

        editEntity.eaten = meal.eaten
        editEntity.what = meal.what
        editEntity.size = Int32(meal.size.rawValue)
        editEntity.nutri = Int64(meal.nutri.rawValue)

        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            NSFLog("Context failed to save: \(meal)")
        }

        return editEntity.meal() ?? meal
    }

    func delete(meal: Meal) {
        guard let existing = entity(from: meal) else {
            return
        }

        let context = container.viewContext
        context.delete(existing)

        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            NSFLog("Context failed to save: \(meal)")
        }
    }
}
