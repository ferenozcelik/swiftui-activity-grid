import Foundation
import SwiftUIActivityGrid

/// A Gregorian calendar in a fixed time zone and locale, so tests don't depend on the machine.
func makeCalendar(timeZone: String = "Europe/Istanbul", firstWeekday: Int = 2) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZone)!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    calendar.firstWeekday = firstWeekday
    return calendar
}

/// A date at the given local time in `calendar`.
func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0, in calendar: Calendar) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

struct TestEntry: ActivityEntry {
    let date: Date
    let value: Double
}
