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
final class NewEditMealViewController<ConcreteViewModel: ViewModel, ConcreteDataProvider: DataProvider>: UIViewController, UITableViewDataSource, ProxyDataSourceDelegate where ConcreteViewModel.InputEnum == EditMealInput, ConcreteViewModel.OutputEnum == EditMealOutput, ConcreteViewModel.ViewState == EditMealViewState, ConcreteDataProvider.CellModel == EditMealCell, ConcreteDataProvider.DataConfig == EditMealDataConfig {
    private let viewModel: ConcreteViewModel
    private let dataProvider: ConcreteDataProvider
    private var disposeBag = DisposeBag()
    private let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: nil)
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: nil, action: nil)
    private let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    private let dateFormatter = DateFormatter()

    required init(viewModel: ConcreteViewModel, dataProvider: ConcreteDataProvider) {
        self.viewModel = viewModel
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = cancelButton

        bindViewState()
        setupTableReaction()
        setupModelOutput()
        setupModelInput()
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
        dataProvider.configure(delegate: self)
    }

    private func setupTableReaction() {
        tableView.rx.itemSelected
            .do(onNext: { [weak self] path in
                self?.tableView.deselectRow(at: path, animated: true)
            })
            .map { path -> EditMealInput in
                return EditMealInput.selectedCellAt(path)
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

                case .confirmDeletion:
                    self?.displayDeleteConfirmation()
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupModelInput() {
        doneButton.rx.tap
            .map { _ -> EditMealInput in
                return .doneTapped
            }
            .bind(to: viewModel.input)
            .disposed(by: disposeBag)
    }

    private func bindViewState() {
        viewModel.viewState
            .map { viewState -> Bool in
                return viewState.hidesCancelButton
            }
            .subscribe(onNext: { [weak self] hidden in
                if hidden {
                    self?.navigationItem.leftBarButtonItem = nil
                } else {
                    self?.navigationItem.leftBarButtonItem = self?.cancelButton
                }
            })
            .disposed(by: disposeBag)

        viewModel.viewState
            .map { viewState -> String in
                return viewState.title
            }
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
    }

    private func configureCell(cell: UITableViewCell, with model: EditMealCell) {
        switch model {
        case .size(size: let size, selected: let selected):
            cell.textLabel?.text = size.forDisplay()
            cell.detailTextLabel?.text = nil
            if selected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

        case .ingredients(nutri: let nutri, selected: let selected):
            cell.textLabel?.text = nutri.forDisplay()
            cell.detailTextLabel?.text = nil
            if selected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

        case .date(let date):
            cell.textLabel?.text = dateFormatter.string(from: date)
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
            cell.accessoryType = .none

        case .delete:
            cell.textLabel?.text = R.string.localizableStrings.edit_meal_delete()
            cell.textLabel?.textColor = UIColor.red
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .none
        }
    }

    private func displayDeleteConfirmation() {
        let alert = UIAlertController(
            title: R.string.localizableStrings.edit_meal_alert_title(),
            message: R.string.localizableStrings.edit_meal_alert_text(),
            preferredStyle: UIAlertControllerStyle.actionSheet
        )
        alert.addAction(
            UIAlertAction.init(
                title: R.string.localizableStrings.edit_meal_alert_delete(),
                style: UIAlertActionStyle.destructive,
                handler: { [weak self] _ in
                    self?.viewModel.input.onNext(EditMealInput.deleteConfirmed)
                }
            )
        )
        alert.addAction(
            UIAlertAction.init(
                title: R.string.localizableStrings.cancel(),
                style: UIAlertActionStyle.cancel,
                handler: nil
            )
        )
        present(alert, animated: true, completion: nil)
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfItems(in: section)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataProvider.titleForHeader(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataProvider.modelForItem(at: indexPath) else {
            return UITableViewCell()
        }

        switch model {
        case .size(_):
            let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "Simple")
            configureCell(cell: cell, with: model)
            return cell

        case .ingredients(_):
            let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "Simple")
            configureCell(cell: cell, with: model)
            return cell

        case .date(_):
            let cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Date")
            configureCell(cell: cell, with: model)
            return cell

        case .delete:
            let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "Delete")
            configureCell(cell: cell, with: model)
            return cell
        }
    }

    // MARK: ProxyDataSourceDelegate

    func batch(changes: [ProxyDataSourceChange]) {
        print(changes)
        tableView.beginUpdates()
        for change in changes {
            switch change {
            case .delete(let ip):
                tableView.deleteRows(at: [ip], with: UITableViewRowAnimation.automatic)

            case .insert(let ip):
                tableView.insertRows(at: [ip], with: UITableViewRowAnimation.automatic)

            case .update(let ip):
                if
                    let cell = tableView.cellForRow(at: ip),
                    let model = dataProvider.modelForItem(at: ip)
                {
                    configureCell(cell: cell, with: model)
                }

            case .insertSection(let sectionIndex):
                tableView.insertSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.automatic)

            case .deleteSection(let sectionIndex):
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: UITableViewRowAnimation.automatic)
            }
        }
        tableView.endUpdates()
    }

    func forceReload() {
        tableView.reloadData()
    }
}
