//
//  ViewModel.swift
//  notsofast
//
//  Created by Yuri Karabatov on 09/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation
import RxSwift

protocol ViewModel {
    /// ViewState is only updated when it is different.
    associatedtype ViewState: Equatable
    associatedtype InputEnum
    associatedtype OutputEnum

    var viewState: ReplaySubject<ViewState> { get }
    var input: PublishSubject<InputEnum> { get }
    var output: PublishSubject<OutputEnum> { get }
}
