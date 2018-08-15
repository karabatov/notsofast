//
//  Meal.swift
//  notsofast
//
//  Created by Yuri Karabatov on 09/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation

enum Serving: Int {
    case nothing = 0
    case bite = 10
    case handful = 20
    case plate = 30
    case bucket = 40

    func forDisplay() -> String {
        switch self {
        case .nothing:
            return R.string.localizableStrings.serving_nothing()

        case .bite:
            return R.string.localizableStrings.serving_bite()

        case .handful:
            return R.string.localizableStrings.serving_handful()

        case .plate:
            return R.string.localizableStrings.serving_plate()

        case .bucket:
            return R.string.localizableStrings.serving_bucket()
        }
    }

    func imageName() -> String {
        switch self {
        case .nothing:
            return ""

        case .bite:
            return R.image.size_bite_32.name

        case .handful:
            return R.image.size_handful_32.name

        case .plate:
            return R.image.size_plate_32.name

        case .bucket:
            return R.image.size_bucket_32.name
        }
    }
}

struct Nutrients: OptionSet {
    let rawValue: Int

    static let protein = Nutrients(rawValue: 1 << 0)
    static let fat = Nutrients(rawValue: 1 << 1)
    static let slowCarb = Nutrients(rawValue: 1 << 2)
    static let fastCarb = Nutrients(rawValue: 1 << 3)

    static let all: Nutrients = [.fastCarb, .protein, .slowCarb, .fat]

    func forDisplay() -> String {
        switch self {
        case Nutrients.fastCarb:
            return R.string.localizableStrings.nutrients_fast_carb_full()

        case Nutrients.protein:
            return R.string.localizableStrings.nutrients_protein_full()

        case Nutrients.slowCarb:
            return R.string.localizableStrings.nutrients_slow_carb_full()

        case Nutrients.fat:
            return R.string.localizableStrings.nutrients_fat_full()

        default:
            var units: [String] = []
            if self.contains(Nutrients.fastCarb) {
                units.append(R.string.localizableStrings.nutrients_fast_carb_short())
            }
            if self.contains(Nutrients.protein) {
                units.append(R.string.localizableStrings.nutrients_protein_short())
            }
            if self.contains(Nutrients.slowCarb) {
                units.append(R.string.localizableStrings.nutrients_slow_carb_short())
            }
            if self.contains(Nutrients.fat) {
                units.append(R.string.localizableStrings.nutrients_fat_short())
            }

            return "[\(units.joined(separator: ", "))]"
        }
    }
}

struct Meal: Equatable {
    let id: URL?
    let eaten: Date
    let size: Serving
    let nutri: Nutrients
    let what: String?

    /// Creates a new meal dated NOW but with empty fields.
    static func createNewMeal() -> Meal {
        return Meal(
            id: nil,
            eaten: Date(),
            size: Serving.nothing,
            nutri: [],
            what: nil
        )
    }
}
