//
//  MealWheelView.swift
//  notsofast
//
//  Created by Yuri Karabatov on 16/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

/// Encapsulating view for displaying the meal wheel collection view.
final class MealWheelView: UIView {
    private let collectionView: UICollectionView

    required init(smth: Int) {
        self.collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        super.init(frame: CGRect.zero)

        setup(collectionView: self.collectionView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(collectionView: UICollectionView) {
        guard collectionView.superview != self else {
            return
        }

        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0))
    }
}
