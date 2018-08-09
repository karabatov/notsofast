//
//  MealListViewController.swift
//  notsofast
//
//  Created by Yuri Karabatov on 06/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import RxSwift

/// Display a list of meals in a collection view.
final class MealListViewController<ConcreteDataSource: ProxyDataSource, ConcreteViewModel: ViewModel>: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ProxyDataSourceDelegate where ConcreteDataSource.CellModel == MealCellModel, ConcreteViewModel.ViewState == MealListViewState {
    /// Scroll the calendar to the past.
    private let leftButton = UIBarButtonItem(image: R.image.arrow_left(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MealListViewController.leftButtonPressed))
    /// Scroll the calendar to the future.
    private let rightButton = UIBarButtonItem(image: R.image.arrow_right(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MealListViewController.rightButtonPressed))
    /// Hovering plus bottom on the bottom right to add a meal.
    /// TODO: Make it tinted to the app's tint color. So, a custom control.
    private let addButton = UIButton(type: UIButtonType.custom)
    /// Custom button in the title of the navbar.
    private let titleButton = UIButton(type: UIButtonType.custom)
    /// Collection view for displaying the list of meals.
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: MealListFlowLayout())
    private let dataSource: ConcreteDataSource
    private let viewModel: ConcreteViewModel
    private var disposeBag = DisposeBag()

    // MARK: System methods

    required init(dataSource: ConcreteDataSource, viewModel: ConcreteViewModel) {
        self.dataSource = dataSource
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.dataSource.configure(delegate: self)

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.titleView = titleButton

        addButton.addTarget(self, action: #selector(MealListViewController.addButtonPressed), for: UIControlEvents.primaryActionTriggered)

        titleButton.addTarget(self, action: #selector(MealListViewController.titleButtonPressed), for: UIControlEvents.primaryActionTriggered)
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.setTitleColor(UIColor.nsfTintColor, for: UIControlState.normal)
        // Set a test title for now before date formatters are attached.
        titleButton.setTitle("Yesterday, 21:00 – Today, 21:00", for: UIControlState.normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        // Keeping the collection view opaque allows showing an “empty” state on the main view background and helps performance.
        collectionView.backgroundColor = UIColor.white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0))

        addButton.setImage(R.image.add_meal_button(), for: UIControlState.normal)
        addButton.showsTouchWhenHighlighted = true
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        let buttonOffset: CGFloat = -12.0
        view.addConstraint(NSLayoutConstraint.init(item: addButton, attribute: NSLayoutAttribute.rightMargin, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: buttonOffset))
        view.addConstraint(NSLayoutConstraint.init(item: addButton, attribute: NSLayoutAttribute.bottomMargin, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: buttonOffset))

        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true

        collectionView.register(MealCollectionViewCell.self, forCellWithReuseIdentifier: MealCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        bindViewState()
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
        openEditMeal(with: Meal.createNewMeal(), title: CreateEditMealTitle.create)
    }

    @objc func titleButtonPressed() {
        NSFLog("Title pressed")
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = dataSource.modelForItem(at: indexPath) else {
            return UICollectionViewCell()
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MealCollectionViewCell.reuseIdentifier, for: indexPath) as! MealCollectionViewCell
        cell.configure(model: model)
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NSFLog("Selected item at \(indexPath)")
        if let model = dataSource.modelForItem(at: indexPath) {
            openEditMeal(with: model.meal, title: CreateEditMealTitle.edit)
        }
    }

    // MARK: ProxyDataSourceDelegate

    func batch(changes: [ProxyDataSourceChange]) {
        let cv = collectionView
        NSFLog("Got \(changes.count) changes.")
        collectionView.performBatchUpdates({
            for change in changes {
                switch change {
                case .delete(let ip):
                    cv.deleteItems(at: [ip])

                case .insert(let ip):
                    cv.insertItems(at: [ip])

                case .update(let ip):
                    cv.reloadItems(at: [ip])

                case .insertSection(let sectionIndex):
                    cv.insertSections(IndexSet.init(integer: sectionIndex))

                case .deleteSection(let sectionIndex):
                    cv.deleteSections(IndexSet.init(integer: sectionIndex))
                }
            }
        }, completion: nil)
    }

    func forceReload() {
        collectionView.reloadData()
    }

    // MARK: ViewModel

    private func bindViewState() {
        viewModel.viewState
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] viewState in
                self?.titleButton.setTitle(viewState.title, for: UIControlState.normal)
            })
            .disposed(by: disposeBag)
    }

    // MARK: Helpers

    private func openEditMeal(with meal: Meal, title: CreateEditMealTitle) {
        let vm = EditMealViewModel(mealStorage: CoreDataProvider.sharedInstance)
        vm.input.onNext(EditMealInput.configure(model: meal, title: title))
        let vc = NewEditMealViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }
}
