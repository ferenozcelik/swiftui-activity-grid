import Foundation

/// A run of consecutive active days.
public struct Streak: Hashable, Sendable {
    /// The start of the first day.
    public let start: Date
    /// The start of the last day.
    public let end: Date
    /// The number of days, including both ends.
    public let length: Int
}

/// Streaks and totals of an ``ActivityGridData``.
///
/// Pure calculations that don't need the view, so you can also use them in a
/// widget's timeline provider or on a profile screen:
///
/// ```swift
/// let stats = ActivityStatistics(data, now: .now)
/// Text("\(stats.currentStreak?.length ?? 0) day streak")
/// ```
public struct ActivityStatistics: Sendable {
    /// A day and its value.
    public struct DayValue: Hashable, Sendable {
        /// The start of the day.
        public let date: Date
        public let value: Double
    }

    /// The streak ending today, or yesterday if today has no activity yet.
    ///
    /// Today doesn't break a streak until it is over, so a streak through
    /// yesterday still counts in the morning. `nil` when neither day is active.
    public let currentStreak: Streak?
    /// The longest streak in the data. The most recent one wins a tie.
    public let longestStreak: Streak?
    /// The number of active days.
    public let activeDays: Int
    /// The sum of all values.
    public let total: Double
    /// The day with the largest value. The earliest one wins a tie.
    public let bestDay: DayValue?

    private let activeKeys: [DayKey]
    private let calendar: Calendar
    private let now: Date

    /// Calculates statistics for `data`.
    ///
    /// - Parameters:
    ///   - data: The daily values.
    ///   - now: The current date. Pass a fixed date in tests and widgets.
    ///   - isActive: Decides whether a day's value counts as activity. By default any value above zero.
    public init(_ data: ActivityGridData, now: Date = .now, isActive: @Sendable (Double) -> Bool = { $0 > 0 }) {
        let calendar = data.calendar
        let days = data.sortedDays
        let active = days.filter { isActive($0.day.value) }

        var longest: Streak?
        var run: (start: Date, end: Date, length: Int)?
        for (key, day) in active {
            if let current = run, DayKey(calendar.addingDays(1, to: current.end), calendar: calendar) == key {
                run = (current.start, day.start, current.length + 1)
            } else {
                run = (day.start, day.start, 1)
            }
            if let run, run.length >= (longest?.length ?? 0) {
                longest = Streak(start: run.start, end: run.end, length: run.length)
            }
        }

        // The last streak up to today is current if it ends today or yesterday. Future days are ignored.
        let todayKey = DayKey(now, calendar: calendar)
        let yesterdayKey = DayKey(calendar.addingDays(-1, to: calendar.startOfDay(for: now)), calendar: calendar)
        var current: Streak?
        if let last = Self.lastStreak(in: active, upTo: todayKey, calendar: calendar),
           last.endKey == todayKey || last.endKey == yesterdayKey {
            current = last.streak
        }

        var best: DayValue?
        for (_, day) in days where day.value > (best?.value ?? 0) {
            best = DayValue(date: day.start, value: day.value)
        }

        self.currentStreak = current
        self.longestStreak = longest
        self.activeDays = active.count
        self.total = days.reduce(0) { $0 + $1.day.value }
        self.bestDay = best
        self.activeKeys = active.map(\.key)
        self.calendar = calendar
        self.now = now
    }

    /// The number of active days inside `range`.
    public func activeDays(in range: ActivityGridRange) -> Int {
        let days = range.days(in: calendar, now: now)
        let start = DayKey(days.lowerBound, calendar: calendar)
        let end = DayKey(days.upperBound, calendar: calendar)
        let lower = activeKeys.partitioningIndex { $0 >= start }
        let upper = activeKeys.partitioningIndex { $0 > end }
        return upper - lower
    }

    /// The last streak that ends on or before `limit`, ignoring days after it.
    private static func lastStreak(
        in active: [(key: DayKey, day: ActivityGridData.Day)],
        upTo limit: DayKey,
        calendar: Calendar
    ) -> (streak: Streak, endKey: DayKey)? {
        guard let lastIndex = active.lastIndex(where: { $0.key <= limit }) else { return nil }
        var firstIndex = lastIndex
        while firstIndex > 0 {
            let previous = active[firstIndex - 1]
            guard DayKey(calendar.addingDays(1, to: previous.day.start), calendar: calendar) == active[firstIndex].key else { break }
            firstIndex -= 1
        }
        let streak = Streak(start: active[firstIndex].day.start, end: active[lastIndex].day.start, length: lastIndex - firstIndex + 1)
        return (streak, active[lastIndex].key)
    }
}
