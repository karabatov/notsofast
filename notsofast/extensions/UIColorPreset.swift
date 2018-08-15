//
//  UIColorPreset.swift
//  notsofast
//
//  Created by Yuri Karabatov on 14/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

extension UIColor {
    /// Global app tint color.
    static let nsfTintColor = UIColor(red: 0.0/255.0, green: 102.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    /// Solid background for rounded cells in the meal list collection view.
    static let mealListCellBackground = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    /// A bit lighter text for meal cell absolute date.
    static let mealListCellAbsDateText = UIColor.darkGray

    /// Protein color.
    static let protein = UIColor(red: 44.0/255.0, green: 213.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    /// Fast carb color.
    static let fastCarb = UIColor(red: 255.0/255.0, green: 158.0/255.0, blue: 61.0/255.0, alpha: 1.0)
    /// Slow carb color.
    static let slowCarb = UIColor(red: 79.0/255.0, green: 235.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    /// Fat color.
    static let fat = UIColor(red: 242.0/255.0, green: 239.0/255.0, blue: 51.0/255.0, alpha: 1.0)
}
