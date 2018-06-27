//
//  MealWheelDataSource.swift
//  notsofast
//
//  Created by Yuri Karabatov on 17/05/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit

/// Connects the meal wheel model to the actual collection view.
final class MealWheelDataSource: NSObject, UITableViewDataSource {
    private let model: MealWheelDataModel
    weak var tableView: UITableView?

    init(model: MealWheelDataModel, tableView: UITableView) {
        self.model = model
        self.tableView = tableView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        NSFLog("Number of sections: \(model.numberOfSections())")
        return model.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSFLog("Number of items: \(model.numberOfItems(in: section))")
        return model.numberOfItems(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let mdl = model.model(forItemAt: indexPath) else {
            return UITableViewCell()
        }

        let cell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: "Meal")
        cell.textLabel?.text = mdl.eaten.debugDescription
        cell.detailTextLabel?.text = "\(mdl.size.forDisplay()), \(mdl.nutri.forDisplay())"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension MealWheelDataSource: MealWheelDataModelDelegate {
    func batch(changes: [DataSourceChange]) {
        guard let tv = tableView else { return }

        tv.beginUpdates()
        for change in changes {
            switch change {
            case .delete(let ip):
                tv.deleteRows(at: [ip], with: UITableViewRowAnimation.automatic)

            case .insert(let ip):
                tv.insertRows(at: [ip], with: UITableViewRowAnimation.automatic)

            case .update(let ip):
                tv.reloadRows(at: [ip], with: UITableViewRowAnimation.automatic)
            }
        }
        tv.endUpdates()
    }
}
