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
    private let textLabel = UILabel(frame: CGRect.zero)
    private let dottedView = DashedBorderView()
    private let selectedBgView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        textLabel.textAlignment = .center
        textLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
        contentView.addConstraint(textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0))
        contentView.addConstraint(textLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8.0))
        contentView.addConstraint(textLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8.0))
        contentView.addConstraint(textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0))

        selectedBgView.layer.masksToBounds = true
        selectedBgView.layer.cornerRadius = 11.0

        selectedBackgroundView = selectedBgView
        backgroundView = dottedView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(nutrient: Nutrients) {
        switch nutrient {
        case Nutrients.protein:
            setupWith(text: Nutrients.protein.forDisplay(), color: UIColor.protein)

        case Nutrients.fastCarb:
            setupWith(text: Nutrients.fastCarb.forDisplay(), color: UIColor.fastCarb)

        case Nutrients.slowCarb:
            setupWith(text: Nutrients.slowCarb.forDisplay(), color: UIColor.slowCarb)

        case Nutrients.fat:
            setupWith(text: Nutrients.fat.forDisplay(), color: UIColor.fat)

        default:
            fatalError("Only singular Nutrients should be supplied for configuration.")
        }
    }

    private func setupWith(text: String, color: UIColor) {
        textLabel.text = text
        dottedView.dashColor = color
        selectedBgView.backgroundColor = color
    }
}
