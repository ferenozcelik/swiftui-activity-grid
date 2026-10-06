import Foundation

/// The days an ``ActivityGrid`` shows.
///
/// Ranges that end "now" use the grid's current date, which you can pin with
/// ``SwiftUICore/View/activityGridNow(_:)``.
public enum ActivityGridRange: Sendable, Hashable {
    /// The last `n` days, including today.
    case lastDays(Int)
    /// The last `n` weeks, including the current week up to today.
    case lastWeeks(Int)
    /// The last `n` months, including the current month up to today. Starts on the first day of a month.
    case lastMonths(Int)
    /// About a year: the current week and the 52 weeks before it. The default.
    case lastYear
    /// A whole year, numbered in the grid's calendar.
    case year(Int)
    /// The whole month containing the date.
    case month(containing: Date)
    /// The days from the start date through the end date, both included.
    case custom(ClosedRange<Date>)

    /// The first and last day of the range, each at the start of its day in `calendar`.
    ///
    /// - Parameters:
    ///   - calendar: The calendar the days are counted in.
    ///   - now: The current date, used by the `last…` ranges.
    public func days(in calendar: Calendar, now: Date) -> ClosedRange<Date> {
        let today = calendar.startOfDay(for: now)
        switch self {
        case .lastDays(let count):
            return calendar.addingDays(-(Swift.max(count, 1) - 1), to: today)...today
        case .lastWeeks(let count):
            let weekStart = calendar.startOfWeek(containing: today)
            return calendar.addingDays(-7 * (Swift.max(count, 1) - 1), to: weekStart)...today
        case .lastMonths(let count):
            let monthStart = calendar.dateInterval(of: .month, for: today)?.start ?? today
            let start = calendar.date(byAdding: .month, value: -(Swift.max(count, 1) - 1), to: monthStart) ?? monthStart
            return calendar.startOfDay(for: start)...today
        case .lastYear:
            let weekStart = calendar.startOfWeek(containing: today)
            return calendar.addingDays(-7 * 52, to: weekStart)...today
        case .year(let year):
            var components = DateComponents()
            components.year = year
            components.month = 1
            components.day = 1
            // Keep the current era so years in era-based calendars (Japanese) mean what the user sees.
            components.era = calendar.component(.era, from: today)
            guard let start = calendar.date(from: components),
                  let interval = calendar.dateInterval(of: .year, for: start)
            else { return today...today }
            return lastDay(of: interval, in: calendar)
        case .month(let date):
            guard let interval = calendar.dateInterval(of: .month, for: date) else { return today...today }
            return lastDay(of: interval, in: calendar)
        case .custom(let range):
            // `ClosedRange` already guarantees lowerBound <= upperBound, so there is nothing to swap.
            return calendar.startOfDay(for: range.lowerBound)...calendar.startOfDay(for: range.upperBound)
        }
    }

    private func lastDay(of interval: DateInterval, in calendar: Calendar) -> ClosedRange<Date> {
        let start = calendar.startOfDay(for: interval.start)
        let end = calendar.startOfDay(for: interval.end.addingTimeInterval(-1))
        return start...end
    }
}
