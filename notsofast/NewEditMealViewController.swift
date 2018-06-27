//
//  NewEditMealViewController.swift
//  notsofast
//
//  Created by Yuri Karabatov on 26/06/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import RxSwift

/// Create or edit a meal.
final class NewEditMealViewController: UIViewController, UITableViewDataSource {
    private let viewModel: EditMealViewModel
    private var disposeBag = DisposeBag()
    private let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    private let data = Variable<[EditMealSection]>.init([])

    required init(viewModel: EditMealViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        setupTitleBind()
        setupTableReload()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))

        tableView.dataSource = self
    }

    private func setupTitleBind() {
        viewModel.title
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] title in
                self?.navigationItem.title = title
            })
            .disposed(by: disposeBag)
    }

    private func setupTableReload() {
        data.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.value.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.value[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data.value[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = data.value[indexPath.section].rows[indexPath.row]
        switch model {
        case .size(size: let size, selected: let selected):
            let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "Simple")
            cell.textLabel?.text = size.forDisplay()
            cell.detailTextLabel?.text = nil
            if selected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell

        case .ingredients(nutri: let nutri, selected: let selected):
            let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "Simple")
            cell.textLabel?.text = nutri.forDisplay()
            cell.detailTextLabel?.text = nil
            if selected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell

        case .date(let date):
            let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "Date")
            cell.textLabel?.text = R.string.localizableStrings.edit_meal_date()
            cell.detailTextLabel?.text = date.description
            cell.accessoryType = .disclosureIndicator
            return cell

        case .delete:
            let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "Delete")
            cell.textLabel?.text = R.string.localizableStrings.edit_meal_delete()
            cell.textLabel?.textColor = UIColor.red
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .none
            return cell
        }
    }
}
