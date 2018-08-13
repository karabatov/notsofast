//
//  NutrientCollectionViewCell.swift
//  notsofast
//
//  Created by Yuri Karabatov on 13/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

/// Displays a single nutrient in a “pill”.
final class NutrientCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "NutrientCollectionViewCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(nutrient: Nutrients) {
    }
}
