//
//  ArrayExtension.swift
//  notsofast
//
//  Created by Yuri Karabatov on 05/12/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= startIndex, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
