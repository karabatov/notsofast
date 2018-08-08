//
//  CollectingFetchDelegate.swift
//  notsofast
//
//  Created by Yuri Karabatov on 08/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import CoreData

@objc protocol CollectingFetchDelegate: NSFetchedResultsControllerDelegate {
    func appendChange(type: NSFetchedResultsChangeType, at indexPath: IndexPath)
    func appendChange(type: NSFetchedResultsChangeType, for section: Int)
    func clearPendingChanges()
    func forwardPendingChanges()

    @objc optional func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    @objc optional func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    @objc optional func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    @objc optional func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
}

extension CollectingFetchDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert, .delete, .update:
            if let newIP = newIndexPath {
                appendChange(type: type, at: newIP)
            }

        case .move:
            if let delIP = indexPath, let newIP = newIndexPath {
                appendChange(type: type, at: delIP)
                appendChange(type: type, at: newIP)
            }
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert, .delete:
            appendChange(type: type, for: sectionIndex)

        // Only insert and delete are sent for sections.
        default:
            break
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        clearPendingChanges()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        forwardPendingChanges()
    }
}

func convertChange(type: NSFetchedResultsChangeType, at indexPath: IndexPath) -> ProxyDataSourceChange {
    switch type {
    case .insert:
        return .insert(indexPath)

    case .delete:
        return .delete(indexPath)

    case .update:
        return .update(indexPath)

    case .move:
        fatalError("Move case should have been handled earlier.")
    }
}

func convertChange(type: NSFetchedResultsChangeType, for section: Int) -> ProxyDataSourceChange {
    switch type {
    case .insert:
        return .insertSection(section)

    case .delete:
        return .deleteSection(section)

    case .move, .update:
        fatalError("Section updates do not support Move or Update.")
    }
}
