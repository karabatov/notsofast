//
//  Constants.swift
//  notsofast
//
//  Created by Yuri Karabatov on 15/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation

/// Abstract class to store constants for the running app.
final class Constants {
    private init() {}

    /// Name for the Core Data model of the app.
    static let coreDataModelName = "MealsModel"

    /// Skeleton format string for compact display of time and date.
    static let preferredDateTimeFormat = "MMMd, h:mm"
}
