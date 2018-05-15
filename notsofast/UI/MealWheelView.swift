//
//  MealWheelView.swift
//  notsofast
//
//  Created by Yuri Karabatov on 16/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

/// Encapsulating view for displaying the meal wheel collection view.
final class MealWheelView: UIView {
    required init(smth: Int) {
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
