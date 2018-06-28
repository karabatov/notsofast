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
    private let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    private let bottomPanel = UIToolbar(frame: CGRect.zero)
    private let plusButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: nil, action: nil)
    /// Display “XX since last meal” on the toolbar.
    private let sinceLastMealLabel = UILabel(frame: CGRect.zero)
    private let dateCompsFormatter = DateComponentsFormatter()
    private let viewModel: TwentyFourListViewModel
    private let dataSource: MealWheelDataSource

    required init(viewModel: TwentyFourListViewModel) {
        self.viewModel = viewModel
        self.dataSource = MealWheelDataSource(model: viewModel.dataModel, tableView: self.tableView)
        viewModel.dataModel.configure(delegate: self.dataSource)

        super.init(nibName: nil, bundle: nil)
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = plusButton
        title = R.string.localizableStrings.last_24_hours()

        dateCompsFormatter.unitsStyle = .abbreviated
        dateCompsFormatter.allowedUnits = [.hour, .minute]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        bottomPanel.isOpaque = true
        bottomPanel.isTranslucent = true

        plusButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.plusButtonTapped()
            })
            .disposed(by: disposeBag)

        configureTableViewReactions()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(bottomPanel)

        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: bottomPanel, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))

        view.addConstraint(NSLayoutConstraint.init(item: bottomPanel, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: bottomPanel, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: bottomPanel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))

        tableView.dataSource = dataSource

        configureBottomPanelButtons()
    }

    private func configureTableViewReactions() {
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] item in
                guard let mdl = self?.viewModel.dataModel.model(forItemAt: item) else {
                    return
                }
                self?.openEditMeal(with: mdl, title: CreateEditMealTitle.edit)
            })
            .disposed(by: disposeBag)
    }

    private func configureBottomPanelButtons() {
        sinceLastMealLabel.translatesAutoresizingMaskIntoConstraints = false
        let btnLabel = UIBarButtonItem(customView: sinceLastMealLabel)
        bottomPanel.setItems([btnLabel], animated: false)

        let llm = viewModel.lastMealModel.lastLoggedMeal
        let timer = Observable<Int>.timer(0.0, period: 5.0, scheduler: MainScheduler.instance)

        Observable.combineLatest(llm, timer) { ($0, $1) }
            .map { [weak self] maybeMeal, _ -> String? in
                let fail = "–"
                guard let meal = maybeMeal else {
                    return fail
                }
                let ti = Date().timeIntervalSince(meal.eaten)
                if let approx = self?.dateCompsFormatter.string(from: ti) {
                    return R.string.localizableStrings.since_last_meal(approx)
                }
                return fail
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "–")
            .drive(sinceLastMealLabel.rx.text)
            .disposed(by: disposeBag)
    }

    private func plusButtonTapped() {
        openEditMeal(with: Meal.createNewMeal(), title: CreateEditMealTitle.create)
    }

    private func openEditMeal(with meal: Meal, title: CreateEditMealTitle) {
        let vm = EditMealViewModel(mealStorage: CoreDataProvider.sharedInstance)
        vm.input.onNext(EditMealInput.configure(model: meal, title: title))
        let vc = NewEditMealViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }
}

