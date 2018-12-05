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
final class MealListViewController<ConcreteDataProvider: DataProvider, ConcreteViewModel: ViewModel>: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ProxyDataSourceDelegate where ConcreteDataProvider.CellModel == MealCellModel, ConcreteDataProvider.DataConfig == MealListDataConfig, ConcreteViewModel.ViewState == MealListViewState, ConcreteViewModel.InputEnum == MealListInput, ConcreteViewModel.OutputEnum == MealListOutput {
    /// Scroll the calendar to the past.
    private let leftButton: UIBarButtonItem = UIBarButtonItem(image: R.image.arrow_left(), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    /// Scroll the calendar to the future.
    private let rightButton = UIBarButtonItem(image: R.image.arrow_right(), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    /// Hovering plus bottom on the bottom right to add a meal.
    /// TODO: Make it tinted to the app's tint color. So, a custom control.
    private let addButton = UIButton(type: UIButtonType.custom)
    /// Custom button in the title of the navbar.
    private let titleButton = UIButton(type: UIButtonType.custom)
    /// Empty state label behind the collection view.
    private let emptyStateLabel = UILabel()
    /// Collection view for displaying the list of meals.
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: MealListFlowLayout())
    private let dataProvider: ConcreteDataProvider
    private let viewModel: ConcreteViewModel
    private var disposeBag = DisposeBag()

    // MARK: System methods

    required init(dataProvider: ConcreteDataProvider, viewModel: ConcreteViewModel) {
        self.dataProvider = dataProvider
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.titleView = titleButton

        addButton.addTarget(self, action: #selector(MealListViewController.addButtonPressed), for: UIControlEvents.primaryActionTriggered)

        titleButton.addTarget(self, action: #selector(MealListViewController.titleButtonPressed), for: UIControlEvents.primaryActionTriggered)
        titleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton.setTitleColor(UIColor.nsfTintColor, for: UIControlState.normal)
        // For some reason, if no title is set initially, the button will come out miniscule.
        titleButton.setTitle("                                                      ", for: UIControlState.normal)

        leftButton.rx.tap
            .map { _ -> MealListInput in
                return .goLeft
            }
            .bind(to: viewModel.input)
            .disposed(by: disposeBag)

        rightButton.rx.tap
            .map { _ -> MealListInput in
                return .goRight
            }
            .bind(to: viewModel.input)
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        emptyStateLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        emptyStateLabel.textColor = UIColor.lightGray
        emptyStateLabel.lineBreakMode = .byWordWrapping
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.adjustsFontSizeToFitWidth = true
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        view.addConstraint(emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        view.addConstraint(emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0))
        view.addConstraint(emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0))

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
        view.addConstraint(addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: buttonOffset))
        if #available(iOS 11.0, *) {
            view.addConstraint(addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: buttonOffset))
        } else {
            view.addConstraint(addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: buttonOffset))
        }

        if #available(iOS 11.0, *) {
        } else {
            collectionView.contentInset.top += 70.0
        }

        collectionView.contentInset.bottom += 30.0
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true

        collectionView.register(MealCollectionViewCell.self, forCellWithReuseIdentifier: MealCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        bindViewState()
        bindModelOutput()
        configureCellTouchingAnimation()
    }

    // MARK: Button targets

    @objc func addButtonPressed() {
        NSFLog("Add pressed")
        openEditMeal(with: Meal.createNewMeal())
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
        viewModel.input.onNext(MealListInput.itemSelected(indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? MealCollectionViewCell)?.willDisplayCell()
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? MealCollectionViewCell)?.didEndDisplayingCell()
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
                    if
                        let mdl = dataSource.modelForItem(at: ip),
                        let cell = cv.cellForItem(at: ip) as? MealCollectionViewCell
                    {
                        cell.configure(model: mdl)
                    }

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
        if #available(iOS 11.0, *) {
        } else {
            // Fixes a bug where UICollectionView would crash with the wrong number of cells from layout.
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: ViewModel

    private func bindViewState() {
        viewModel.viewState
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] viewState in
                self?.titleButton.setTitle(viewState.title, for: UIControlState.normal)
                self?.rightButton.isEnabled = viewState.enableCalendarRightButton
                self?.collectionView.isHidden = viewState.listOfMealsHidden
                self?.emptyStateLabel.text = viewState.emptyStateText
            })
            .disposed(by: disposeBag)
    }

    private func bindModelOutput() {
        viewModel.output
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] output in
                switch output {
                case .openEditMeal(meal: let meal):
                    self?.openEditMeal(with: meal)
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: Helpers

    private func openEditMeal(with meal: Meal) {
        let vm = EditMealViewModel(mealStorage: CoreDataProvider.sharedInstance)
        vm.dataConfig.onNext(EditMealDataConfig(meal: meal, editingDate: false))
        let vc = NewEditMealViewController(viewModel: vm, dataProvider: vm)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }

    private func configureCellTouchingAnimation() {
        var animatedIndexPath: IndexPath?
        let pressedTransform = CGAffineTransform.identity.scaledBy(x: 0.97, y: 0.97)
        collectionView.panGestureRecognizer.rx.event
            .subscribe(onNext: { [weak self] event in
                guard let cv = self?.collectionView else { return }
                let point = event.location(in: cv)
                let indexPath = cv.indexPathForItem(at: point)

                switch event.state {
                case .began:
                    if
                        let indexPath = indexPath,
                        let cell = cv.cellForItem(at: indexPath)
                    {
                        self?.animate(cell: cell, to: pressedTransform)
                        animatedIndexPath = indexPath
                    }

                case .changed:
                    if
                        indexPath != animatedIndexPath,
                        let cip = animatedIndexPath,
                        let cell = cv.cellForItem(at: cip)
                    {
                        if cell.transform != CGAffineTransform.identity {
                            self?.animate(cell: cell, to: CGAffineTransform.identity)
                        }
                    } else if
                        indexPath == animatedIndexPath,
                        let cip = indexPath,
                        let cell = cv.cellForItem(at: cip)
                    {
                        if cell.transform != pressedTransform {
                            self?.animate(cell: cell, to: pressedTransform)
                        }
                    }

                default:
                    if
                        let cip = animatedIndexPath,
                        let cell = cv.cellForItem(at: cip)
                    {
                        self?.animate(cell: cell, to: CGAffineTransform.identity)
                        animatedIndexPath = nil
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func animate(cell: UICollectionViewCell, to transform: CGAffineTransform) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 3,
            options: [.curveEaseInOut],
            animations: {
                cell.transform = transform
            },
        completion: nil)
    }
}
