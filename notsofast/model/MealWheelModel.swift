//
//  MealWheelModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 17/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation

/// Represents the logical data source for the meal wheel.
protocol MealWheelDataModel {
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func model(forItemAt indexPath: IndexPath) -> Meal
}
