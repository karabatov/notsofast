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
final class NewEditMealViewController<ConcreteViewModel: ViewModel>: UIViewController, UITableViewDataSource where ConcreteViewModel.InputEnum == EditMealInput, ConcreteViewModel.OutputEnum == EditMealOutput {
    private let viewModel: ConcreteViewModel
    private var disposeBag = DisposeBag()
    private let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: nil)
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: nil, action: nil)
    private let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    private var data: [EditMealSection] = []
    private let dateFormatter = DateFormatter()

    required init(viewModel: ConcreteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        // setupTitleBind()
        // setupTableReload()
        setupTableReaction()
        setupModelOutput()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))

        tableView.dataSource = self
    }

    /*
    private func setupTitleBind() {
        viewModel.title
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] title in
                self?.navigationItem.title = title
            })
            .disposed(by: disposeBag)
    }
    */

    /*
    private func setupTableReload() {
        viewModel.data
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .drive(onNext: { [weak self] newData in
                self?.data = newData
            })
            .disposed(by: disposeBag)
    }
    */

    private func setupTableReaction() {
        tableView.rx.itemSelected
            .do(onNext: { [weak self] path in
                self?.tableView.deselectRow(at: path, animated: true)
            })
            .map { [unowned self] path -> EditMealInput in
                return EditMealInput.selectedCell(self.data[path.section].rows[path.row])
            }
            .bind(to: viewModel.input)
            .disposed(by: disposeBag)
    }

    private func setupModelOutput() {
        viewModel.output
            .subscribe(onNext: { [weak self] output in
                switch output {
                case .dismissController:
                    self?.parent?.dismiss(animated: true, completion: nil)

                case .reloadSection(_):
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = data[indexPath.section].rows[indexPath.row]
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
            cell.textLabel?.text = dateFormatter.string(from: date)
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .none
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
