//
//  DateExtension.swift
//  notsofast
//
//  Created by Yuri Karabatov on 10/08/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import Foundation

extension Date {
    static func sutki() -> TimeInterval {
        return -24.0 * 60.0 * 60.0
    }

    /// Returns current day at midnight. Drops hours, minutes and seconds.
    func beginningOfDay() -> Date {
        return Calendar.autoupdatingCurrent.startOfDay(for: self)
    }

    /// Returns the start of the current hour.
    func beginningOfNextHour() -> Date {
        let comps = Calendar.autoupdatingCurrent.dateComponents([.calendar, .timeZone, .year, .month, .day, .hour], from: self)
        return Calendar.autoupdatingCurrent.date(from: comps)!.addingTimeInterval(60.0 * 60.0)
    }

    /// Returns the start of the next hour rewinded by 24 hours.
    /// E.g. if now is 20:42 it will return yesterday, 21:00.
    func beginningOfNextHourYesterday() -> Date {
        return self.beginningOfNextHour().addingTimeInterval(-Date.sutki())
    }
}
