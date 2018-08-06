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
    private let leftButton = UIBarButtonItem(image: R.image.arrow_left(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MealListViewController.leftButtonPressed))
    private let rightButton = UIBarButtonItem(image: R.image.arrow_right(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MealListViewController.rightButtonPressed))

    // MARK: System methods

    required init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Navbar items

    @objc func leftButtonPressed() {
        NSFLog("Left pressed")
    }

    @objc func rightButtonPressed() {
        NSFLog("Left pressed")
    }
}
