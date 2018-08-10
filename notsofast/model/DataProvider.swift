//
//  DataProvider.swift
//  notsofast
//
//  Created by Yuri Karabatov on 07/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxSwift

protocol DataProvider: ProxyDataSource {
    associatedtype DataConfig: Equatable

    var dataConfig: ReplaySubject<DataConfig> { get }
}
