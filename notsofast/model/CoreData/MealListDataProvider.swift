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

struct MealListDataSection: DataSourceSection {
    typealias CellModel = Meal
    let name: String?
    let items: [Meal]
}

@objc final class MealListDataProvider: NSObject, DataProvider, NSFetchedResultsControllerDelegate {
    private var frc: NSFetchedResultsController<MealEntity>
    private var disposeBag = DisposeBag()

    init(frc: NSFetchedResultsController<MealEntity>, config: MealListDataConfig) {
        self.dataConfig.onNext(config)
        self.frc = frc
        super.init()

        self.frc.delegate = self

        self.dataConfig
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] dc in
                NSFetchedResultsController<MealEntity>.deleteCache(withName: frc.cacheName)
                frc.fetchRequest.predicate = NSPredicate(format: "eaten >= %@ and eaten <= %@", argumentArray: [dc.startDate, dc.endDate])
                try? frc.performFetch()
                self?.updateData(from: frc)
            })
            .disposed(by: disposeBag)
    }

    private func updateData(from frc: NSFetchedResultsController<MealEntity>) {
        var sections = [MealListDataSection]()

        for (idx, section) in (frc.sections ?? []).enumerated() {
            var items = [Meal]()
            for item in 0..<section.numberOfObjects {
                let ip = IndexPath(row: item, section: idx)
                if let meal = frc.object(at: ip).meal() {
                    items.append(meal)
                }
            }

            let mealSection = MealListDataSection(
                name: section.name,
                items: items
            )
            sections.append(mealSection)
        }

        data.onNext(sections)
    }

    // MARK: DataProvider

    typealias DataConfig = MealListDataConfig
    let dataConfig = ReplaySubject<MealListDataConfig>.create(bufferSize: 1)

    // MARK: DataSourceProvider

    typealias Section = MealListDataSection
    let data = ReplaySubject<[Section]>.create(bufferSize: 1)
}
