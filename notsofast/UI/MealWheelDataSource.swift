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

    init(model: MealWheelDataModel) {
        self.model = model
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfItems(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _ = model.model(forItemAt: indexPath)
        return UITableViewCell()
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
