//
//  EditMealViewModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 26/06/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxSwift

struct EditMealSection {
    let title: String?
    let rows: [EditMealCell]
}

enum EditMealCell {
    case size(Serving)
    case ingredients(Nutrients)
    case date(Date)
    case delete
}

/// View model for the create/edit meal view controller.
final class EditMealViewModel {
    let data = ReplaySubject<[EditMealSection]>.create(bufferSize: 1)

    required init() {
        data.onNext([])
    }
}
