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
}

/// Maintains a Core Data stack and returns preconfigured results controllers.
final class CoreDataProvider {
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

    /// Returns a preconfigured fetched results controller for the target place to be used.
    func fetchedResultsController(for target: FetchResultsTarget) -> NSFetchedResultsController<MealEntity> {
        switch target {
        case .twentyFourHourList:
            let fr = NSFetchRequest<MealEntity>(entityName: "MealEntity")
            fr.sortDescriptors = [NSSortDescriptor(key: "eaten", ascending: true)]
            return NSFetchedResultsController(
                fetchRequest: fr,
                managedObjectContext: container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }
    }
}
