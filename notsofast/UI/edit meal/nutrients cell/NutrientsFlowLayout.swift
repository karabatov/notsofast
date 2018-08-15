//
//  NutrientsFlowLayout.swift
//  notsofast
//
//  Created by Yuri Karabatov on 13/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

protocol NutrientsFlowLayoutDelegate: class {
    func textLengthForItem(at indexPath: IndexPath) -> Int?
    func preferredCellHeight() -> CGFloat
}

final class NutrientsFlowLayout: UICollectionViewFlowLayout {
    private var contentBounds = CGRect.zero
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()

    weak var delegate: NutrientsFlowLayoutDelegate?

    override init() {
        super.init()

        self.sectionInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 16.0, right: 0.0)

        self.scrollDirection = .vertical
        self.minimumLineSpacing = 16.0
        self.minimumInteritemSpacing = 16.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()

        guard let cv = collectionView else { return }

        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: CGPoint.zero, size: CGSize(width: cv.bounds.width, height: 0.0))

        createAttributes()
    }

    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }

        return newBounds.width != cv.bounds.width
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Normally this would be overkill, but in our case we have all elements onscreen all the time.
        return cachedAttributes
    }

    /// For every item:
    /// - Prepare attributes.
    /// - Store attributes in `cachedAttributes` array.
    /// - Union `contentBounds` with attributes frame.
    private func createAttributes() {
        guard
            let cv = collectionView,
            let elemH = delegate?.preferredCellHeight(),
            cv.bounds.width > minimumInteritemSpacing * 3.0
        else { return }

        let numi = cv.numberOfItems(inSection: 0)

        // Add top section inset before first row.
        contentBounds.size.height += sectionInset.top

        /// Track current origin height to calculate frame.
        var height: CGFloat = contentBounds.size.height

        // Stride through indices in pairs e.g. (0, 1), (2, 3) because we need relative width of the elements.
        for idx in stride(from: 0, through: numi, by: 2) {
            guard idx < numi else { break }

            let ip1 = IndexPath(item: idx, section: 0)
            let ip2 = IndexPath(item: idx + 1, section: 0)

            let len1 = delegate?.textLengthForItem(at: ip1) ?? 0
            let len2 = delegate?.textLengthForItem(at: ip2) ?? 0

            /// Relative length for first item, 0.0...1.0.
            let relLen1: CGFloat

            // Make both elements equal width.
            switch (len1, len2) {
            case (0, 0),
                 (0, _) where idx + 1 < numi,
                 (_, 0) where idx + 1 < numi:
                relLen1 = 0.5

            case (_, _) where idx + 1 >= numi:
                relLen1 = 1.0

            default:
                relLen1 = CGFloat(len1) / CGFloat(len1 + len2)
            }

            // Add inter-line spacing on top if we're not on the first row.
            if idx > 0 {
                height += minimumLineSpacing
            }

            let la1 = UICollectionViewLayoutAttributes(forCellWith: ip1)
            var la2: UICollectionViewLayoutAttributes?

            if relLen1 == 1.0 {
                let frame1 = CGRect(x: minimumInteritemSpacing, y: height, width: contentBounds.width - minimumInteritemSpacing * 2.0, height: elemH)
                la1.frame = frame1
            } else {
                let availableWidth = contentBounds.width - minimumInteritemSpacing * 3.0
                let width1 = ceil(availableWidth * relLen1)
                let frame1 = CGRect(x: minimumInteritemSpacing, y: height, width: width1, height: elemH)
                la1.frame = frame1

                let frame2 = CGRect(x: minimumInteritemSpacing * 2.0 + width1, y: height, width: availableWidth - width1, height: elemH)
                la2 = UICollectionViewLayoutAttributes(forCellWith: ip2)
                la2?.frame = frame2
            }

            if let la2 = la2 {
                cachedAttributes.append(la2)
                contentBounds = contentBounds.union(la2.frame)
            }
            cachedAttributes.append(la1)
            contentBounds = contentBounds.union(la1.frame)
            height = contentBounds.height
        }

        // Add bottom section inset after last row.
        contentBounds.size.height += sectionInset.bottom
    }
}
