//
//  MealEntityExtension.swift
//  notsofast
//
//  Created by Yuri Karabatov on 17/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation

extension MealEntity {
    /// Generates a Meal value from a MealEntity (from Core Data).
    func meal() -> Meal? {
        guard
            let date = self.eaten,
            let size = Serving(rawValue: Int(self.size))
        else {
            return nil
        }

        return Meal(
            id: objectID.uriRepresentation(),
            eaten: date,
            size: size,
            nutri: Nutrients(rawValue: Int(self.nutri)),
            what: self.what
        )
    }

    @objc func sectionName() -> String {
        guard
            let date = eaten,
            let compsDate = Calendar.current.dateComponents([.calendar,.timeZone,.year,.month,.day,], from: date).date
        else {
            return "none"
        }

        return String(compsDate.timeIntervalSince1970)
    }
}
