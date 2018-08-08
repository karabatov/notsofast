//
//  CollectingFetchDelegate.swift
//  notsofast
//
//  Created by Yuri Karabatov on 08/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import CoreData

protocol CollectingFetchDelegate: class {
    var forwardDelegate: CollectingFetchForwardDelegate? { get set }
    func setupForwardDelegate<T: NSFetchRequestResult>(frc: NSFetchedResultsController<T>)

    func append(change: ProxyDataSourceChange)
    func clearPendingChanges()
    func forwardPendingChanges()
}

extension CollectingFetchDelegate {
    func setupForwardDelegate<T: NSFetchRequestResult>(frc: NSFetchedResultsController<T>) {
        if forwardDelegate == nil {
            forwardDelegate = CollectingFetchForwardDelegate()
        }
        frc.delegate = forwardDelegate
        forwardDelegate?.fetchDelegate = self
    }
}

final class CollectingFetchForwardDelegate: NSObject, NSFetchedResultsControllerDelegate {
    weak var fetchDelegate: CollectingFetchDelegate?

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIP = newIndexPath {
                fetchDelegate?.append(change: ProxyDataSourceChange.insert(newIP))
            }

        case .delete:
            if let delIP = indexPath {
                fetchDelegate?.append(change: ProxyDataSourceChange.delete(delIP))
            }

        case .update:
            if let updIP = indexPath {
                fetchDelegate?.append(change: ProxyDataSourceChange.update(updIP))
            }

        case .move:
            if let delIP = indexPath, let newIP = newIndexPath {
                fetchDelegate?.append(change: ProxyDataSourceChange.delete(delIP))
                fetchDelegate?.append(change: ProxyDataSourceChange.insert(newIP))
            }
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            fetchDelegate?.append(change: ProxyDataSourceChange.insertSection(sectionIndex))

        case .delete:
            fetchDelegate?.append(change: ProxyDataSourceChange.deleteSection(sectionIndex))

        // Only insert and delete are sent for sections.
        default:
            break
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        fetchDelegate?.clearPendingChanges()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        fetchDelegate?.forwardPendingChanges()
    }
}
