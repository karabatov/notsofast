//
//  DataProvider.swift
//  notsofast
//
//  Created by Yuri Karabatov on 07/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxSwift

protocol DataSourceSection {
    associatedtype CellModel

    var name: String? { get }
    var items: [CellModel] { get }
}

protocol DataSourceProvider {
    associatedtype Section: DataSourceSection

    var data: ReplaySubject<[Section]> { get }
}

protocol DataProvider: DataSourceProvider {
    associatedtype DataConfig: Equatable

    var dataConfig: ReplaySubject<DataConfig> { get }
}
