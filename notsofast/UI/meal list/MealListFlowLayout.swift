//
//  MealListFlowLayout.swift
//  notsofast
//
//  Created by Yuri Karabatov on 09/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

final class MealListFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()

        self.minimumInteritemSpacing = 20.0
        self.minimumLineSpacing = 20.0
        self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        calculateEstimatedSize()
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        calculateEstimatedSize()
        super.invalidateLayout(with: context)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return true }

        return newBounds.width != cv.bounds.width
    }

    private func calculateEstimatedSize() {
        guard let cv = collectionView else { return }
        itemSize = UICollectionViewFlowLayout.automaticSize

        if #available(iOS 11.0, *) {
            self.sectionInsetReference = .fromSafeArea
        }

        var estSize = CGSize(width: cv.bounds.width, height: 80.0)
        estSize.width -= cv.contentInset.left + cv.contentInset.right
        estSize.width -= sectionInset.left + sectionInset.right
        estSize.width -= cv.layoutMargins.left + cv.layoutMargins.right

        if #available(iOS 11.0, *) {
            estSize.width -= cv.safeAreaInsets.left + cv.safeAreaInsets.right
        }

        self.estimatedItemSize = estSize
    }
}
