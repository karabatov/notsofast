//
//  NewEditMealViewController.swift
//  notsofast
//
//  Created by Yuri Karabatov on 26/06/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import RxSwift

/// Create or edit a meal.
final class NewEditMealViewController: UIViewController {
    private let viewModel: EditMealViewModel
    private var disposeBag = DisposeBag()

    required init(viewModel: EditMealViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        setupTitleBind()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func setupTitleBind() {
        viewModel.title
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] title in
                self?.navigationItem.title = title
            })
            .disposed(by: disposeBag)
    }
}
