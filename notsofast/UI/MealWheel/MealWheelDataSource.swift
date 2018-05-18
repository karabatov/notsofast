//
//  MealWheelDataSource.swift
//  notsofast
//
//  Created by Yuri Karabatov on 17/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

/// Connects the meal wheel model to the actual collection view.
final class MealWheelDataSource: NSObject, UICollectionViewDataSource {
    private let model: MealWheelDataModel
    weak var collectionView: UICollectionView?

    init(model: MealWheelDataModel) {
        self.model = model
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _ = model.model(forItemAt: indexPath)
        return UICollectionViewCell()
    }
}

extension MealWheelDataSource: MealWheelDataModelDelegate {
    func batch(changes: [DataSourceChange]) {
        guard let cv = collectionView else { return }
        cv.performBatchUpdates({
            for change in changes {
                switch change {
                case .delete(let ip):
                    cv.deleteItems(at: [ip])

                case .insert(let ip):
                    cv.insertItems(at: [ip])

                case .update(let ip):
                    cv.reloadItems(at: [ip])
                }
            }
        }, completion: nil)
    }
}
