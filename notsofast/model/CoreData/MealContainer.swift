//
//  MealContainer.swift
//  notsofast
//
//  Created by Yuri Karabatov on 17/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import CoreData

/// Centralized Core Data stack access.
final class MealContainer: NSPersistentContainer {
    /// Shared instance for the Core Data stack.
    private let instance = NSPersistentContainer(name: Constants.coreDataModelName)
}
