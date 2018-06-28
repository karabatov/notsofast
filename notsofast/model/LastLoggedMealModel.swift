//
//  LastLoggedMealModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 28/06/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

/// Returns a stream of latest meals (maximum one).
protocol LastLoggedMealModel {
    var lastLoggedMeal: Observable<Meal?> { get }
}

/// A live implementation of `LastLoggedMealModel` protocol.
final class LastLoggedMealLiveModel: NSObject, LastLoggedMealModel, NSFetchedResultsControllerDelegate {
    private let frc: NSFetchedResultsController<MealEntity>
    private let mealSignal = ReplaySubject<Meal?>.create(bufferSize: 1)

    init(frc: NSFetchedResultsController<MealEntity>) {
        self.frc = frc
        super.init()
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            fatalError("Failed to fetch! No live updates!")
        }
        updateObservableFromController()
    }

    var lastLoggedMeal: Observable<Meal?> {
        return mealSignal
    }

    private func updateObservableFromController() {
        guard
            let sections = frc.sections,
            let section = sections.first,
            let mealEnt = section.objects?.first as? MealEntity,
            let meal = mealEnt.meal()
        else {
            mealSignal.onNext(nil)
            return
        }

        mealSignal.onNext(meal)
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateObservableFromController()
    }
}
