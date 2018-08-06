//
//  MealListViewController.swift
//  notsofast
//
//  Created by Yuri Karabatov on 06/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

/// Display a list of meals in a collection view.
final class MealListViewController: UIViewController {
    /// Scroll the calendar to the past.
    private let leftButton = UIBarButtonItem(image: R.image.arrow_left(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MealListViewController.leftButtonPressed))
    /// Scroll the calendar to the future.
    private let rightButton = UIBarButtonItem(image: R.image.arrow_right(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MealListViewController.rightButtonPressed))
    /// Hovering plus bottom on the bottom right to add a meal.
    private let addButton = UIButton(type: UIButtonType.custom)

    // MARK: System methods

    required init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton

        addButton.addTarget(self, action: #selector(MealListViewController.addButtonPressed), for: UIControlEvents.primaryActionTriggered)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addButton.setImage(R.image.add_meal_button(), for: UIControlState.normal)
        addButton.showsTouchWhenHighlighted = true
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        let buttonOffset: CGFloat = -12.0
        view.addConstraint(NSLayoutConstraint.init(item: addButton, attribute: NSLayoutAttribute.rightMargin, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: buttonOffset))
        view.addConstraint(NSLayoutConstraint.init(item: addButton, attribute: NSLayoutAttribute.bottomMargin, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: buttonOffset))
    }

    // MARK: Button targets

    @objc func leftButtonPressed() {
        NSFLog("Left pressed")
    }

    @objc func rightButtonPressed() {
        NSFLog("Left pressed")
    }

    @objc func addButtonPressed() {
        NSFLog("Add pressed")
    }
}
