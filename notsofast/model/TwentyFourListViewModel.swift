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

    required init(dataModel: MealWheelDataModel) {
        self.dataModel = dataModel
    }

    class func liveViewModel() -> TwentyFourListViewModel {
    }
}
