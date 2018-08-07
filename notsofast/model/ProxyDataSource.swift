//
//  ProxyDataSource.swift
//  notsofast
//
//  Created by Yuri Karabatov on 07/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation

protocol ProxyDataSource {
    associatedtype CellModel

    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func modelForItem(at indexPath: IndexPath) -> CellModel?

    var delegate: ProxyDataSourceDelegate? { get set }
}

enum ProxyDataSourceChange {
    case insert(IndexPath)
    case delete(IndexPath)
    case update(IndexPath)
}

protocol ProxyDataSourceDelegate {
    func batch(changes: [ProxyDataSourceChange])
    func forceReload()
}
