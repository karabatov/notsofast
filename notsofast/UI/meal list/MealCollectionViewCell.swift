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

        df.setLocalizedDateFormatFromTemplate(Constants.preferredDateTimeFormat)

        return df
    }()
    private let servingImageView = UIImageView(frame: CGRect.zero)
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
    private lazy var sizingWidthConstraint: NSLayoutConstraint = {
        let c = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        c.isActive = false
        return c
    }()
    /// When there is no serving, display the serving size text flush to the left.
    private var servingLeftConstraint: NSLayoutConstraint?
    /// When there is no serving image, display the label flush to the left.
    private let servingLeftNoImageOffset: CGFloat = 16.0
    /// When there is a serving image, display the image view and give it space.
    private let servingLeftWithImageOffset: CGFloat = 56.0

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

        servingImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(servingImageView)

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
            "image": servingImageView,
            "serving": servingLabel,
            "relative": relativeDateLabel,
            "absolute": absoluteDateLabel,
            "nutri": nutriContainer
        ]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[image(32)]", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[serving]-(>=8)-[relative]-16-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[absolute]-16-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[nutri]-16-|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[serving]-12-[absolute]-12-[nutri(4)]|", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=0)-[image(32)]", options: NSLayoutConstraint.FormatOptions.init(rawValue: 0), metrics: nil, views: views))
        contentView.addConstraint(servingImageView.centerYAnchor.constraint(equalTo: servingLabel.centerYAnchor))
        contentView.addConstraint(relativeDateLabel.firstBaselineAnchor.constraint(equalTo: servingLabel.firstBaselineAnchor))
        let servingLeft = servingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 56.0)
        servingLeftConstraint = servingLeft
        contentView.addConstraint(servingLeft)
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

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        sizingWidthConstraint.constant = targetSize.width
        sizingWidthConstraint.isActive = true
        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: UILayoutPriority.required,
            verticalFittingPriority: verticalFittingPriority
        )
        sizingWidthConstraint.isActive = false
        contentView.translatesAutoresizingMaskIntoConstraints = true
        return size
    }

    func configure(model: MealCellModel) {
        self.model = model

        servingImageView.image = model.meal.size.image()
        servingLabel.text = model.size
        absoluteDateLabel.text = MealCollectionViewCell.absDateFormatter.string(from: model.date)
        configureRelativeDateLabel(displayElapsed: model.displayElapsedTime, date: model.date)

        if model.meal.size == .nothing {
            servingImageView.isHidden = true
            servingLeftConstraint?.constant = servingLeftNoImageOffset
        } else {
            servingImageView.isHidden = false
            servingLeftConstraint?.constant = servingLeftWithImageOffset
        }

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
        if let descr = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.subheadline).withSymbolicTraits(UIFontDescriptor.SymbolicTraits.traitItalic) {
            subhead = UIFont(descriptor: descr, size: descr.pointSize)
        } else {
            subhead = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        }

        return FontSet(
            title3Font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title3),
            bodyFont: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
            headlineFont: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline),
            subheadItalicFont: subhead
        )
    }

    private func agoStr(from relativeDate: String) -> NSAttributedString {
        let fontSet = MealCollectionViewCell.fontSet
        let regularAttrs = [
            NSAttributedString.Key.font: fontSet.bodyFont
        ]
        let boldAttrs = [
            NSAttributedString.Key.font: fontSet.headlineFont
        ]
        let agoStr = NSMutableAttributedString(string: R.string.localizableStrings.meal_relative_ago(relativeDate), attributes: regularAttrs)
        if let rangeOfDate = agoStr.string.range(of: relativeDate) {
            agoStr.setAttributes(boldAttrs, range: NSRange(rangeOfDate, in: agoStr.string))
        }

        return agoStr
    }
}
