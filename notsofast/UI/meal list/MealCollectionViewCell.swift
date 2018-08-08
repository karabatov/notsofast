//
//  MealCollectionViewCell.swift
//  notsofast
//
//  Created by Yuri Karabatov on 08/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

final class MealCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MealCollectionViewCell"
    private let servingLabel = UILabel(frame: CGRect.zero)
    private let absoluteDateLabel = UILabel(frame: CGRect.zero)
    private let relativeDateLabel = UILabel(frame: CGRect.zero)
    private let proteinView = UIView(frame: CGRect.zero)
    private let fastCarbView = UIView(frame: CGRect.zero)
    private let slowCarbView = UIView(frame: CGRect.zero)
    private let fatView = UIView(frame: CGRect.zero)
    private let nutriContainer = UIStackView(frame: CGRect.zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    private func commonInit() {
        backgroundColor = UIColor.mealListCellBackground
        layer.masksToBounds = true
        layer.cornerRadius = 10.0

        servingLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(servingLabel)

        relativeDateLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(relativeDateLabel)

        absoluteDateLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(absoluteDateLabel)

        nutriContainer.axis = .horizontal
        nutriContainer.alignment = .fill
        nutriContainer.spacing = 0.0
        nutriContainer.distribution = .fillEqually
        nutriContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nutriContainer)

        nutriContainer.addArrangedSubview(proteinView)
        nutriContainer.addArrangedSubview(fastCarbView)
        nutriContainer.addArrangedSubview(slowCarbView)
        nutriContainer.addArrangedSubview(fatView)

        let views = [
            "serving": servingLabel,
            "relative": relativeDateLabel,
            "absolute": absoluteDateLabel,
            "nutri": nutriContainer
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[serving]-(>=8)-[relative]-16-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[absolute]-16-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[nutri]-16-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[serving]-12-[absolute]-12-[nutri(4)]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views))
        addConstraint(NSLayoutConstraint.init(item: relativeDateLabel, attribute: NSLayoutAttribute.firstBaseline, relatedBy: NSLayoutRelation.equal, toItem: servingLabel, attribute: NSLayoutAttribute.firstBaseline, multiplier: 1.0, constant: 0.0))
    }

    func configure(model: MealCellModel) {
        servingLabel.text = model.size
        absoluteDateLabel.text = model.absoluteDate
        relativeDateLabel.attributedText = model.relativeDate

        func colorView(view: UIView, nutri: Nutrients, color: UIColor) {
            if model.nutrients.contains(nutri) {
                view.backgroundColor = color
            } else {
                view.backgroundColor = UIColor.clear
            }
        }

        colorView(view: proteinView, nutri: Nutrients.protein, color: UIColor.protein)
        colorView(view: fastCarbView, nutri: Nutrients.fastCarb, color: UIColor.fastCarb)
        colorView(view: slowCarbView, nutri: Nutrients.slowCarb, color: UIColor.slowCarb)
        colorView(view: fatView, nutri: Nutrients.fat, color: UIColor.fat)
    }
}
