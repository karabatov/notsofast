//
//  FRCDataProvider.swift
//  notsofast
//
//  Created by Yuri Karabatov on 07/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class FRCDataProvider<T: NSFetchRequestResult, S: DataSourceSection, C: Equatable>: NSObject, DataProvider, NSFetchedResultsControllerDelegate {
    private let frc: NSFetchedResultsController<T>
    private var disposeBag = DisposeBag()
    private let applyDataConfigChange: (C, NSFetchedResultsController<T>) -> Void
    private let itemToCellModel: (T) -> Section.CellModel?

    init(
        frc: NSFetchedResultsController<T>,
        config: C,
        applyDataConfigChange: @escaping (C, NSFetchedResultsController<T>) -> Void,
        itemToCellModel: @escaping (T) -> Section.CellModel?
    )
    {
        self.dataConfig.onNext(config)
        self.frc = frc
        self.applyDataConfigChange = applyDataConfigChange
        self.itemToCellModel = itemToCellModel
        super.init()

        self.frc.delegate = self

        self.dataConfig
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] dataConfig in
                NSFetchedResultsController<T>.deleteCache(withName: frc.cacheName)
                self?.applyDataConfigChange(dataConfig, frc)
                try? frc.performFetch()
                self?.updateData(from: frc)
            })
            .disposed(by: disposeBag)
    }

    private func updateData(from frc: NSFetchedResultsController<T>) {
        var sections = [S]()

        for (idx, section) in (frc.sections ?? []).enumerated() {
            let items = (0..<section.numberOfObjects)
                .map { IndexPath(row: $0, section: idx) }
                .map { frc.object(at: $0) }
                .compactMap(itemToCellModel)

            sections.append(S(name: section.name, items: items))
        }

        data.onNext(sections)
    }

    // MARK: DataProvider

    typealias DataConfig = C
    let dataConfig = ReplaySubject<DataConfig>.create(bufferSize: 1)

    // MARK: DataSourceProvider

    typealias Section = S
    let data = ReplaySubject<[Section]>.create(bufferSize: 1)

    // MARK: NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateData(from: controller as! NSFetchedResultsController<T>)
    }
}
