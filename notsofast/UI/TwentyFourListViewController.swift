//
//  TwentyFourListViewController.swift
//  notsofast
//
//  Created by Yuri Karabatov on 28/04/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// Displays a list of meals for the last 24 hours.
final class TwentyFourListViewController: UIViewController {
    private var disposeBag = DisposeBag()
    private let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    private let bottomPanel = UIToolbar(frame: CGRect.zero)
    private let plusButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: nil, action: nil)

    required init(viewModel: TwentyFourListViewModel) {
        super.init(nibName: nil, bundle: nil)
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = plusButton
        title = R.string.localizableStrings.last_24_hours()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        plusButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.plusButtonTapped()
            })
            .disposed(by: disposeBag)

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

    private func plusButtonTapped() {
        NSFLog("Plus button tapped.")
    }
}

