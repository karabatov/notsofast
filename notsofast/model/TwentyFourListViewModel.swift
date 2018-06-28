//
//  TwentyFourListViewModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 19/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation

/// View model for `TwentyFourListViewController`.
final class TwentyFourListViewModel {
    let dataModel: MealWheelDataModel
    let lastMealModel: LastLoggedMealModel

    required init(dataModel: MealWheelDataModel, lastMeal: LastLoggedMealModel) {
        self.dataModel = dataModel
        self.lastMealModel = lastMeal
    }

    /// Returns an initialized instance of itself for use in live app.
    class func liveViewModel() -> TwentyFourListViewModel {
        let frc = CoreDataProvider.sharedInstance.fetchedResultsController(for: FetchResultsTarget.twentyFourHourList)
        let dataModel = MealWheelLiveModel(frc: frc)

        let frc2 = CoreDataProvider.sharedInstance.fetchedResultsController(for: FetchResultsTarget.lastRecordedMeal)
        let lastMealModel = LastLoggedMealLiveModel(frc: frc2)
        return TwentyFourListViewModel(dataModel: dataModel, lastMeal: lastMealModel)
    }
}
