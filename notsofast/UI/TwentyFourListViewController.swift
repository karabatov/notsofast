//
//  TwentyFourListViewController.swift
//  notsofast
//
//  Created by Yuri Karabatov on 28/04/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import Rswift

class TwentyFourListViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        navigationItem.largeTitleDisplayMode = .automatic
        title = R.string.localizableStrings.last_24_hours()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

