import Foundation

/// Identifies one calendar day in a given calendar, independent of the time of day.
///
/// Built from the era, year, month and day components, so it works for any
/// calendar (including eras that restart the year, like the Japanese calendar)
/// and is never thrown off by DST days that are 23 or 25 hours long.
struct DayKey: Hashable, Comparable, Sendable {
    let rawValue: Int

    init(_ date: Date, calendar: Calendar) {
        let components = calendar.dateComponents([.era, .year, .month, .day], from: date)
        let era = components.era ?? 0
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        // Months stay below 100 even in 13-month calendars, days below 100 in every calendar.
        rawValue = ((era * 100_000 + year) * 100 + month) * 100 + day
    }

    static func < (lhs: DayKey, rhs: DayKey) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Calendar {
    /// Adds whole days with calendar arithmetic, never with 86 400 second steps.
    func addingDays(_ days: Int, to date: Date) -> Date {
        self.date(byAdding: .day, value: days, to: date) ?? date
    }

    /// The first day of the week containing `date`, honoring `firstWeekday`.
    func startOfWeek(containing date: Date) -> Date {
        let day = startOfDay(for: date)
        let weekday = component(.weekday, from: day)
        let offset = (weekday - firstWeekday + 7) % 7
        return startOfDay(for: addingDays(-offset, to: day))
    }
}
