//
//  NSFLog.swift
//  notsofast
//
//  Created by Yuri Karabatov on 25/06/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation

func NSFLog(_ s: String, file: String = #file, line: Int = #line, function: String = #function) {
    #if DEBUG
    print("\(file) line \(line), \(function) > \(s)")
    #endif
}
