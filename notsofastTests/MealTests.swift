//
//  MealTests.swift
//  notsofastTests
//
//  Created by Yuri Karabatov on 05/12/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import XCTest
@testable import notsofast

class MealTests: XCTestCase {

    func testEmptyMeal() {
        let meal1 = Meal.createNewMeal()
        let meal2 = Meal.createNewMeal()
        XCTAssert(meal1 != meal2, "Two empty meals should be different because the dates are different.")
    }

}
