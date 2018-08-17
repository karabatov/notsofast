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

    func isEmpty() -> Bool
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func titleForHeader(in section: Int) -> String?
    func modelForItem(at indexPath: IndexPath) -> CellModel?

    func configure(delegate: ProxyDataSourceDelegate?)
}

enum ProxyDataSourceChange {
    case insert(IndexPath)
    case delete(IndexPath)
    case update(IndexPath)

    case insertSection(Int)
    case deleteSection(Int)
}

protocol ProxyDataSourceDelegate: AnyObject {
    func batch(changes: [ProxyDataSourceChange])
    func forceReload()
}
