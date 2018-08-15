//
//  ServingExtension.swift
//  notsofast
//
//  Created by Yuri Karabatov on 15/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

extension Serving {
    /// Returns an image representation of Serving.
    func image() -> UIImage? {
        guard !self.imageName().isEmpty else {
            return nil
        }

        return UIImage(named: self.imageName())
    }
}
