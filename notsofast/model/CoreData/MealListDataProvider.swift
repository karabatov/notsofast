//
//  MealListDataProvider.swift
//  notsofast
//
//  Created by Yuri Karabatov on 07/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

struct MealListDataConfig: Equatable {
    let startDate: Date
    let endDate: Date
}

@objc final class MealListDataProvider: NSObject, DataProvider, CollectingFetchDelegate {
    private var frc: NSFetchedResultsController<MealEntity>
    private var disposeBag = DisposeBag()

    init(frc: NSFetchedResultsController<MealEntity>, config: MealListDataConfig) {
        self.dataConfig.onNext(config)
        self.frc = frc
        super.init()
        setupForwardDelegate(frc: frc)

        self.dataConfig
            .distinctUntilChanged()
            .debug("MLDP")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] dc in
                NSFetchedResultsController<MealEntity>.deleteCache(withName: frc.cacheName)
                frc.fetchRequest.predicate = NSPredicate(format: "eaten >= %@ and eaten <= %@", argumentArray: [dc.startDate, dc.endDate])
                try? frc.performFetch()
                self?.dataSourceDelegate?.forceReload()
            })
            .disposed(by: disposeBag)
    }

    // MARK: DataProvider

    typealias DataConfig = MealListDataConfig
    let dataConfig = ReplaySubject<MealListDataConfig>.create(bufferSize: 1)

    // MARK: ProxyDataSource

    private weak var dataSourceDelegate: ProxyDataSourceDelegate?

    typealias CellModel = Meal

    func configure(delegate: ProxyDataSourceDelegate?) {
        dataSourceDelegate = delegate
    }

    func isEmpty() -> Bool {
        return frc.fetchedObjects?.isEmpty ?? true
    }

    func numberOfSections() -> Int {
        return frc.sections?.count ?? 0
    }

    func numberOfItems(in section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }

    func modelForItem(at indexPath: IndexPath) -> Meal? {
        return frc.object(at: indexPath).meal()
    }

    func titleForHeader(in section: Int) -> String? {
        return frc.sections?[section].name
    }

    // MARK: CollectingFetchDelegate

    private var changeCollector = [ProxyDataSourceChange]()

    var forwardDelegate: CollectingFetchForwardDelegate?

    func append(change: ProxyDataSourceChange) {
        changeCollector.append(change)
    }

    func clearPendingChanges() {
        changeCollector.removeAll(keepingCapacity: true)
    }

    func forwardPendingChanges() {
        dataSourceDelegate?.batch(changes: changeCollector)
    }
}
