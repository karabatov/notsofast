//
//  TwentyFourListViewController.swift
//  notsofast
//
//  Created by Yuri Karabatov on 28/04/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import Rswift

/// Displays a list of meals for the last 24 hours.
final class TwentyFourListViewController: UIViewController {
    private let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    private let bottomPanel = UIToolbar(frame: CGRect.zero)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        navigationItem.largeTitleDisplayMode = .automatic
        title = R.string.localizableStrings.last_24_hours()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(bottomPanel)

        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))

        view.addConstraint(NSLayoutConstraint.init(item: bottomPanel, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: bottomPanel, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: bottomPanel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
    }
}

