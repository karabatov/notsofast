//
//  NewEditMealViewController.swift
//  notsofast
//
//  Created by Yuri Karabatov on 26/06/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

extension DataSourceSection: SectionModelType {
    typealias Item = T

    init(original: DataSourceSection<T>, items: [T]) {
        self = DataSourceSection<T>.init(
            name: original.name,
            items: items
        )
    }
}

/// Create or edit a meal.
final class NewEditMealViewController<ConcreteViewModel: ViewModel, ConcreteDataProvider: DataProvider>: UIViewController where ConcreteViewModel.InputEnum == EditMealInput, ConcreteViewModel.OutputEnum == EditMealOutput, ConcreteViewModel.ViewState == EditMealViewState, ConcreteDataProvider.CellModel == EditMealCell, ConcreteDataProvider.DataConfig == EditMealDataConfig {
    private let viewModel: ConcreteViewModel
    private let dataProvider: ConcreteDataProvider
    private var disposeBag = DisposeBag()
    private let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: nil)
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: nil, action: nil)
    private let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    private var dateFormatter: DateFormatter = {
        let df = DateFormatter()

        df.setLocalizedDateFormatFromTemplate(Constants.preferredDateTimeFormat)

        return df
    }()
    private var agoDateFormatter: DateComponentsFormatter = {
        let df = DateComponentsFormatter()

        df.unitsStyle = .abbreviated
        df.allowedUnits = [.hour, .minute]

        return df
    }()
    /// Index path to scroll to after updates.
    private var scrollToIndexPath: IndexPath?
    /// We want to update the date text in the cell automatically.
    private let autoupdatingDateCellIndexPath = ReplaySubject<IndexPath?>.create(bufferSize: 1)

    required init(viewModel: ConcreteViewModel, dataProvider: ConcreteDataProvider) {
        self.viewModel = viewModel
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)

        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = cancelButton

        bindViewState()
        setupTableReaction()
        setupAutoUpdateDateCell()
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

        tableView.register(DateSelectorTableViewCell.self, forCellReuseIdentifier: DateSelectorTableViewCell.reuseIdentifier)
        tableView.register(NutrientsTableViewCell.self, forCellReuseIdentifier: NutrientsTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension

        let dataSource = RxTableViewSectionedReloadDataSource<DataSourceSection<EditMealCell>>.init(
            configureCell: { [weak self] ds, tv, ip, model -> UITableViewCell in
                switch model {
                case .size(_):
                    let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "Simple")
                    self?.configureCell(cell: cell, with: model)
                    return cell

                case .ingredients(_):
                    let cell = tv.dequeueReusableCell(withIdentifier: NutrientsTableViewCell.reuseIdentifier)!
                    self?.configureCell(cell: cell, with: model)
                    return cell

                case .date(_):
                    let cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Date")
                    self?.configureCell(cell: cell, with: model)
                    self?.autoupdatingDateCellIndexPath.onNext(ip)
                    return cell

                case .delete:
                    let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "Delete")
                    self?.configureCell(cell: cell, with: model)
                    return cell

                case .editDate(_):
                    let cell = tv.dequeueReusableCell(withIdentifier: DateSelectorTableViewCell.reuseIdentifier)!
                    self?.configureCell(cell: cell, with: model)
                    self?.autoupdatingDateCellIndexPath.onNext(nil)
                    return cell
                }
            },
            titleForHeaderInSection: { (ds, sectionIndex) -> String? in
                return ds.sectionModels[sectionIndex].name
            }
        )

        dataProvider.data
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
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

    private func setupAutoUpdateDateCell() {
        /*
        Observable<Int>.timer(60.0, period: 60.0, scheduler: MainScheduler.asyncInstance)
            .withLatestFrom(autoupdatingDateCellIndexPath)
            .subscribe(onNext: { [weak self] maybeIP in
                guard
                    let ip = maybeIP,
                    let cell = self?.tableView.cellForRow(at: ip),
                    let model = self?.dataProvider.modelForItem(at: ip),
                    cell.reuseIdentifier == self?.reuseIdentifier(for: model)
                else {
                    return
                }

                self?.configureCell(cell: cell, with: model)
            })
            .disposed(by: disposeBag)
        */
    }

    private func setupModelOutput() {
        viewModel.output
            .subscribe(onNext: { [weak self] output in
                switch output {
                case .dismissController:
                    self?.parent?.dismiss(animated: true, completion: nil)

                case .confirmDeletion:
                    self?.displayDeleteConfirmation()

                case .scrollToRowAfterUpdates(let indexPath):
                    self?.scrollToIndexPath = indexPath
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

        cancelButton.rx.tap
            .map { _ -> EditMealInput in
                return .cancelTapped
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
            cell.imageView?.image = UIImage(named: size.imageName())
            if selected {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

        case .ingredients(nutri: let nutri):
            guard let cell = cell as? NutrientsTableViewCell else { return }
            cell.configure(nutri: nutri)
            cell.selectedNutrients
                .map { nutri -> EditMealInput in
                    return .selectedNutrients(nutri)
                }
                .bind(to: viewModel.input)
                .disposed(by: cell.disposeBag)

        case .date(let date):
            cell.imageView?.image = nil
            cell.textLabel?.text = dateFormatter.string(from: date)
            let ago = Date().timeIntervalSince(date)
            if ago < 60.0 {
                cell.detailTextLabel?.text = R.string.localizableStrings.meal_relative_now()
            } else {
                if let relativeDate = agoDateFormatter.string(from: ago) {
                    cell.detailTextLabel?.text = R.string.localizableStrings.meal_relative_ago(relativeDate)
                } else {
                    cell.detailTextLabel?.text = nil
                }
            }
            cell.accessoryType = .disclosureIndicator

        case .editDate(let date):
            guard let cell = cell as? DateSelectorTableViewCell else { return }
            cell.configure(date: date)
            cell.selectedDate
                .map { date -> EditMealInput in
                    return .selectedDate(date)
                }
                .bind(to: viewModel.input)
                .disposed(by: cell.disposeBag)

        case .delete:
            cell.imageView?.image = nil
            cell.textLabel?.text = R.string.localizableStrings.edit_meal_delete()
            cell.textLabel?.textColor = UIColor.red
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .none
        }
    }

    private func displayDeleteConfirmation() {
        let alertStyle: UIAlertControllerStyle
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            alertStyle = .actionSheet

        default:
            alertStyle = .alert
        }

        let alert = UIAlertController(
            title: R.string.localizableStrings.edit_meal_alert_title(),
            message: R.string.localizableStrings.edit_meal_alert_text(),
            preferredStyle: alertStyle
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

    private func reuseIdentifier(for model: EditMealCell) -> String {
        switch model {
        case .date(_):
            return "Date"

        case .delete:
            return "Delete"

        case .editDate(_):
            return DateSelectorTableViewCell.reuseIdentifier

        case .ingredients(_):
            return NutrientsTableViewCell.reuseIdentifier

        case .size(_):
            return "Simple"
        }
    }
}
