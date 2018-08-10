//
//  MealCollectionViewCell.swift
//  notsofast
//
//  Created by Yuri Karabatov on 08/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import RxSwift

private struct FontSet {
    let title3Font: UIFont
    let bodyFont: UIFont
    let headlineFont: UIFont
    let subheadItalicFont: UIFont
}

final class MealCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "MealCollectionViewCell"
    private static var agoDateFormatter: DateComponentsFormatter = {
        let df = DateComponentsFormatter()

        df.maximumUnitCount = 1
        df.unitsStyle = .abbreviated
        df.allowedUnits = [.hour, .minute]

        return df
    }()
    private static var absDateFormatter: DateFormatter = {
        let df = DateFormatter()

        df.dateStyle = .medium
        df.timeStyle = .short

        return df
    }()
    private let servingLabel = UILabel(frame: CGRect.zero)
    private let absoluteDateLabel = UILabel(frame: CGRect.zero)
    private let relativeDateLabel = UILabel(frame: CGRect.zero)
    private let proteinView = UIView(frame: CGRect.zero)
    private let fastCarbView = UIView(frame: CGRect.zero)
    private let slowCarbView = UIView(frame: CGRect.zero)
    private let fatView = UIView(frame: CGRect.zero)
    private let nutriContainer = UIStackView(frame: CGRect.zero)
    private var agoTimer: Observable<Int>?
    private var timerDisposeBag = DisposeBag()

    /// This will come in handy when watching the font size change.
    private var model: MealCellModel?

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    private func commonInit() {
        contentView.backgroundColor = UIColor.mealListCellBackground
        layer.masksToBounds = true
        layer.cornerRadius = 10.0

        servingLabel.font = MealCollectionViewCell.fontSet.title3Font
        servingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(servingLabel)

        relativeDateLabel.font = MealCollectionViewCell.fontSet.bodyFont
        relativeDateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(relativeDateLabel)

        absoluteDateLabel.font = MealCollectionViewCell.fontSet.subheadItalicFont
        absoluteDateLabel.textColor = UIColor.mealListCellAbsDateText
        absoluteDateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(absoluteDateLabel)

        nutriContainer.axis = .horizontal
        nutriContainer.alignment = .fill
        nutriContainer.spacing = 0.0
        nutriContainer.distribution = .fillEqually
        nutriContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nutriContainer)

        nutriContainer.addArrangedSubview(proteinView)
        nutriContainer.addArrangedSubview(fastCarbView)
        nutriContainer.addArrangedSubview(slowCarbView)
        nutriContainer.addArrangedSubview(fatView)

        let views = [
            "serving": servingLabel,
            "relative": relativeDateLabel,
            "absolute": absoluteDateLabel,
            "nutri": nutriContainer
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[serving]-(>=8)-[relative]-16-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[absolute]-16-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[nutri]-16-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[serving]-12-[absolute]-12-[nutri(4)]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraint(relativeDateLabel.firstBaselineAnchor.constraint(equalTo: servingLabel.firstBaselineAnchor))
    }

    func willDisplayCell() {
        setupElapsedTimer()
    }

    func didEndDisplayingCell() {
        timerDisposeBag = DisposeBag()
    }

    override func prepareForReuse() {
        timerDisposeBag = DisposeBag()
    }

    func configure(model: MealCellModel) {
        self.model = model

        servingLabel.text = model.size
        absoluteDateLabel.text = MealCollectionViewCell.absDateFormatter.string(from: model.date)
        configureRelativeDateLabel(displayElapsed: model.displayElapsedTime, date: model.date)

        func colorView(view: UIView, nutri: Nutrients, color: UIColor) {
            if model.nutrients.contains(nutri) {
                view.backgroundColor = color
            } else {
                view.backgroundColor = UIColor.clear
            }
        }

        colorView(view: proteinView, nutri: Nutrients.protein, color: UIColor.protein)
        colorView(view: fastCarbView, nutri: Nutrients.fastCarb, color: UIColor.fastCarb)
        colorView(view: slowCarbView, nutri: Nutrients.slowCarb, color: UIColor.slowCarb)
        colorView(view: fatView, nutri: Nutrients.fat, color: UIColor.fat)
    }

    private func configureRelativeDateLabel(displayElapsed: Bool, date: Date) {
        guard displayElapsed else {
            relativeDateLabel.attributedText = nil
            return
        }

        let ago = Date().timeIntervalSince(date)
        if ago < 60.0 {
            relativeDateLabel.text = R.string.localizableStrings.meal_relative_now()
        } else {
            let formattedElapsed: String
            if let formStr = MealCollectionViewCell.agoDateFormatter.string(from: ago) {
                formattedElapsed = formStr
            } else {
                formattedElapsed = ""
            }
            relativeDateLabel.attributedText = agoStr(from: formattedElapsed)
        }
    }

    private func setupElapsedTimer() {
        timerDisposeBag = DisposeBag()
        agoTimer = Observable<Int>.timer(60.0, period: 60.0, scheduler: MainScheduler.asyncInstance)
        agoTimer?
            .subscribe(onNext: { [weak self] _ in
                if let model = self?.model {
                    self?.configureRelativeDateLabel(displayElapsed: model.displayElapsedTime, date: model.date)
                }
            })
            .disposed(by: timerDisposeBag)
    }

    // MARK: Dynamic fonts
    // TODO: Subscribe to font size change notifications.

    private static var fontSet = MealCollectionViewCell.createFontSet()

    private static func createFontSet() -> FontSet {
        let subhead: UIFont
        if let descr = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.subheadline).withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitItalic) {
            subhead = UIFont(descriptor: descr, size: descr.pointSize)
        } else {
            subhead = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        }

        return FontSet(
            title3Font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.title3),
            bodyFont: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
            headlineFont: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
            subheadItalicFont: subhead
        )
    }

    private func agoStr(from relativeDate: String) -> NSAttributedString {
        let fontSet = MealCollectionViewCell.fontSet
        let regularAttrs = [
            NSAttributedStringKey.font: fontSet.bodyFont
        ]
        let boldAttrs = [
            NSAttributedStringKey.font: fontSet.headlineFont
        ]
        let agoStr = NSMutableAttributedString(string: R.string.localizableStrings.meal_relative_ago(relativeDate), attributes: regularAttrs)
        if let rangeOfDate = agoStr.string.range(of: relativeDate) {
            agoStr.setAttributes(boldAttrs, range: NSRange(rangeOfDate, in: agoStr.string))
        }

        return agoStr
    }
}
