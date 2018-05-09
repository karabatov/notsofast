//
//  Meal.swift
//  notsofast
//
//  Created by Yuri Karabatov on 09/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation

enum Serving: Int {
    case bite = 10
    case handful = 20
    case plate = 30
    case bucket = 40
}

struct Nutrients: OptionSet {
    let rawValue: Int

    static let protein = Nutrients(rawValue: 1 << 0)
    static let fat = Nutrients(rawValue: 1 << 1)
    static let slowCarb = Nutrients(rawValue: 1 << 2)
    static let fastCarb = Nutrients(rawValue: 1 << 3)

    static let all: Nutrients = [.protein, .fat, .slowCarb, .fastCarb]
}

struct Meal {
    let eaten: Date
    let size: Serving
    let nutri: Nutrients
}
