//
//  DataSourceSectionExtension.swift
//  notsofast
//
//  Created by Yuri Karabatov on 05/12/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxDataSources

extension DataSourceSection: SectionModelType {
    typealias Item = T

    init(original: DataSourceSection<T>, items: [T]) {
        self = DataSourceSection<T>.init(
            name: original.name,
            items: items
        )
    }
}
