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

protocol MealActionController {
    func upsert(meal: Meal, original: Meal)
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

    /// Returns a preconfigured fetched results controller for the target place to be used.
    func fetchedResultsController(for target: FetchResultsTarget) -> NSFetchedResultsController<MealEntity> {
        switch target {
        case .twentyFourHourList:
            let fr = NSFetchRequest<MealEntity>(entityName: "MealEntity")
            fr.sortDescriptors = [NSSortDescriptor(key: "eaten", ascending: true)]
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

    // MARK: MealActionController

    func upsert(meal: Meal, original: Meal) {
        let context = container.viewContext

        let fr = NSFetchRequest<MealEntity>(entityName: "MealEntity")
        fr.predicate = NSPredicate(format: "eaten = %@", argumentArray: [original.eaten])

        guard let mealsCount = try? context.count(for: fr) else { return }

        switch mealsCount {
        case 0:
            let newMealEntity = MealEntity(entity: MealEntity.entity(), insertInto: context)
            newMealEntity.eaten = meal.eaten
            newMealEntity.what = meal.what
            newMealEntity.size = Int32(meal.size.rawValue)
            newMealEntity.nutri = Int64(meal.nutri.rawValue)

        case 1:
            if
                let meals = try? context.fetch(fr),
                meals.count == 1,
                let firstMeal = meals.first
            {
                firstMeal.eaten = meal.eaten
                firstMeal.what = meal.what
                firstMeal.size = Int32(meal.size.rawValue)
                firstMeal.nutri = Int64(meal.nutri.rawValue)
            }

        default:
            return
        }

        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            NSFLog("Context failed to save: \(meal)")
        }
    }

    func delete(meal: Meal) {
        let context = container.viewContext

        let fr = NSFetchRequest<MealEntity>(entityName: "MealEntity")
        fr.predicate = NSPredicate(format: "eaten = %@", argumentArray: [meal.eaten])

        guard let mealsCount = try? context.count(for: fr), mealsCount == 1 else { return }

        if
            let meals = try? context.fetch(fr),
            meals.count == 1,
            let firstMeal = meals.first
        {
            context.delete(firstMeal)
        }

        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            NSFLog("Context failed to save: \(meal)")
        }
    }
}
