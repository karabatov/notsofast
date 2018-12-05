//
//  DataProvider.swift
//  notsofast
//
//  Created by Yuri Karabatov on 07/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxSwift

struct DataSourceSection<T: Equatable>: Equatable {
    let name: String?
    let items: [T]
}

protocol DataSourceProvider {
    associatedtype CellModel: Equatable

    var data: ReplaySubject<[DataSourceSection<CellModel>]> { get }
}

protocol DataProvider: DataSourceProvider {
    associatedtype DataConfig: Equatable

    var dataConfig: ReplaySubject<DataConfig> { get }
}
