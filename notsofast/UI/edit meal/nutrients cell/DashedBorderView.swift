//
//  DashedBorderView.swift
//  notsofast
//
//  Created by Yuri Karabatov on 13/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

final class DashedBorderView: UIView {
    var dashColor: UIColor = UIColor.black {
        didSet {
            backgroundColor = UIColor.white
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1.0, dy: 1.0), cornerRadius: 11.0)

        dashColor.setStroke()
        path.lineWidth = 2.0

        let dashPattern: [CGFloat] = [5.0, 5.0]
        path.setLineDash(dashPattern, count: 2, phase: 0)
        path.stroke()
    }}
