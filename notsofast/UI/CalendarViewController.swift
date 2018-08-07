//
//  CalendarViewController.swift
//  notsofast
//
//  Created by Yuri Karabatov on 06/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

/// Display a calendar.
final class CalendarViewController: UIViewController {
    private let todayButton = UIBarButtonItem(title: R.string.localizableStrings.calendar_today(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CalendarViewController.todayButtonTapped))
    private let doneButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(CalendarViewController.doneButtonTapped))

    required init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.hidesBackButton = true
        navigationItem.title = R.string.localizableStrings.calendar_title()
        navigationItem.leftBarButtonItem = todayButton
        navigationItem.rightBarButtonItem = doneButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @objc func todayButtonTapped() {

    }

    @objc func doneButtonTapped() {

    }
}
