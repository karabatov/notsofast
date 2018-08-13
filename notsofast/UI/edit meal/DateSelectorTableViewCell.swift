//
//  DateSelectorTableViewCell.swift
//  notsofast
//
//  Created by Yuri Karabatov on 13/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import RxSwift

class DateSelectorTableViewCell: UITableViewCell {
    static let reuseIdentifier = "DateSelectorTableViewCell"

    private let dateSelector = UIDatePicker(frame: CGRect.zero)
    var disposeBag = DisposeBag()
    let selectedDate = PublishSubject<Date>()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        dateSelector.datePickerMode = .dateAndTime

        dateSelector.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateSelector)
        contentView.addConstraint(dateSelector.topAnchor.constraint(equalTo: contentView.topAnchor))
        contentView.addConstraint(dateSelector.leftAnchor.constraint(equalTo: contentView.leftAnchor))
        contentView.addConstraint(dateSelector.rightAnchor.constraint(equalTo: contentView.rightAnchor))
        contentView.addConstraint(dateSelector.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    func configure(date: Date) {
        disposeBag = DisposeBag()

        dateSelector.maximumDate = Date()
        dateSelector.date = date

        dateSelector.rx.date
            .bind(to: selectedDate)
            .disposed(by: disposeBag)
    }
}
