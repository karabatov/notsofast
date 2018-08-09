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

        self.minimumInteritemSpacing = 10
        self.minimumLineSpacing = 10
        self.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        guard let collectionView = collectionView else { return nil }
        if #available(iOS 11.0, *) {
            layoutAttributes.bounds.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        } else {
            layoutAttributes.bounds.size.width = collectionView.layoutMarginsGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        }
        return layoutAttributes
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superLayoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        guard scrollDirection == .vertical else { return superLayoutAttributes }

        let computedAttributes = superLayoutAttributes.compactMap { layoutAttribute in
            return layoutAttribute.representedElementCategory == .cell ? layoutAttributesForItem(at: layoutAttribute.indexPath) : layoutAttribute
        }

        return computedAttributes
    }

}
