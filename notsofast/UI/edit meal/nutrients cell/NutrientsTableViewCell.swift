//
//  NutrientsTableViewCell.swift
//  notsofast
//
//  Created by Yuri Karabatov on 13/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import RxSwift

final class NutrientsTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, NutrientsFlowLayoutDelegate {
    static let reuseIdentifier = "NutrientsTableViewCell"
    private static let defaultRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 200.0, height: 150.0))
    private let flowLayout = NutrientsFlowLayout()
    private lazy var collectionView = {
        return UICollectionView(frame: NutrientsTableViewCell.defaultRect, collectionViewLayout: flowLayout)
    }()
    var disposeBag = DisposeBag()
    let selectedNutrients = PublishSubject<Nutrients>()
    /// IndexPath.item to Selected.
    private var selectDict = [Int: Bool]()
    private let prefNutri = [Nutrients.protein, Nutrients.fastCarb, Nutrients.slowCarb, Nutrients.fat]
    private lazy var collHeight: NSLayoutConstraint = {
        return collectionView.heightAnchor.constraint(equalToConstant: 150.0)
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        collectionView.backgroundColor = UIColor.white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        contentView.addConstraint(collectionView.topAnchor.constraint(equalTo: contentView.topAnchor))
        contentView.addConstraint(collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor))
        contentView.addConstraint(collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor))
        contentView.addConstraint(collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        contentView.addConstraint(collHeight)

        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.register(NutrientCollectionViewCell.self, forCellWithReuseIdentifier: NutrientCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        flowLayout.delegate = self

        flowLayout.prepare()
        collHeight.constant = flowLayout.collectionViewContentSize.height
        NSFLog("CV height: \(collHeight.constant)")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        disposeBag = DisposeBag()
        selectDict.removeAll(keepingCapacity: true)
    }

    func configure(nutri: Nutrients) {
        disposeBag = DisposeBag()
        for (idx, item) in prefNutri.enumerated() {
            if nutri.contains(item) {
                selectDict[idx] = true
                collectionView.selectItem(at: IndexPath(item: idx, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.init(rawValue: 0))
            } else {
                selectDict[idx] = false
                collectionView.deselectItem(at: IndexPath(item: idx, section: 0), animated: false)
            }
        }
    }

    private func animateTap(on cell: UICollectionViewCell) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0.0,
            options: [.curveEaseOut],
            animations: {
                cell.transform = CGAffineTransform.identity.scaledBy(x: 0.97, y: 0.97)
            },
            completion: nil
        )
        UIView.animate(
            withDuration: 0.2,
            delay: 0.1,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 3,
            options: [.curveEaseInOut],
            animations: {
                cell.transform = CGAffineTransform.identity
            },
            completion: nil
        )
    }

    private func outputSelectedNutri() {
        var set: Nutrients = []
        for (idx, nutri) in prefNutri.enumerated() {
            if selectDict[idx] ?? false {
                set.insert(nutri)
            }
        }

        selectedNutrients.onNext(set)
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return prefNutri.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NutrientCollectionViewCell.reuseIdentifier, for: indexPath) as! NutrientCollectionViewCell
        cell.configure(nutrient: prefNutri[indexPath.item])
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectDict[indexPath.item] = true
        if let cell = collectionView.cellForItem(at: indexPath) {
            animateTap(on: cell)
        }
        outputSelectedNutri()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectDict[indexPath.item] = false
        if let cell = collectionView.cellForItem(at: indexPath) {
            animateTap(on: cell)
        }
        outputSelectedNutri()
    }

    // MARK: NutrientsFlowLayoutDelegate

    private static var cellHeight: CGFloat = 0.0
    private static let sizingCell = NutrientCollectionViewCell(frame: NutrientsTableViewCell.defaultRect)

    func textLengthForItem(at indexPath: IndexPath) -> Int? {
        guard indexPath.item < prefNutri.count else {
            return nil
        }

        return prefNutri[indexPath.item].forDisplay().count
    }

    func preferredCellHeight() -> CGFloat {
        if NutrientsTableViewCell.cellHeight > 0.0 {
            return NutrientsTableViewCell.cellHeight
        }

        NutrientsTableViewCell.sizingCell.configure(nutrient: Nutrients.protein)
        let size = NutrientsTableViewCell.sizingCell.systemLayoutSizeFitting(NutrientsTableViewCell.defaultRect.size, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.fittingSizeLevel)
        NSFLog("Cell size: \(size)")

        NutrientsTableViewCell.cellHeight = size.height
        return size.height
    }
}
