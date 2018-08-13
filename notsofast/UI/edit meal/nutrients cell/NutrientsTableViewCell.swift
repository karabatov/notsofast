//
//  NutrientsTableViewCell.swift
//  notsofast
//
//  Created by Yuri Karabatov on 13/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import RxSwift

final class NutrientsTableViewCell: UITableViewCell, UICollectionViewDataSource {
    static let reuseIdentifier = "NutrientsTableViewCell"
    private let flowLayout = NutrientsFlowLayout()
    private lazy var collectionView = {
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
    }()
    var disposeBag = DisposeBag()
    let selectedNutrients = PublishSubject<Nutrients>()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        contentView.addConstraint(collectionView.topAnchor.constraint(equalTo: contentView.topAnchor))
        contentView.addConstraint(collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor))
        contentView.addConstraint(collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor))
        contentView.addConstraint(collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        disposeBag = DisposeBag()
    }

    func configure(nutri: Nutrients) {

    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
