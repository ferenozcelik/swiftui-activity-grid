import Foundation

/// Daily values, normalized to calendar days.
///
/// Building it groups every date into its day in `calendar` and combines
/// several values on one day with `aggregation`. ``ActivityGrid`` builds one for
/// you from a dictionary or a collection of ``ActivityEntry`` values. With a lot
/// of data (several years), build it once, keep it, and pass it to the grid
/// instead, so it isn't rebuilt every time the view updates.
///
/// Values that are not finite (NaN, infinity) are dropped. Negative values are
/// treated as zero; they are not supported.
public struct ActivityGridData: Sendable, Equatable {
    /// How several values on the same day are combined.
    public enum Aggregation: Sendable, Hashable {
        /// Adds the values up. The default.
        case sum
        /// Keeps the largest value.
        case max
        /// Keeps the value with the latest date.
        case last
        /// Uses the mean of the values.
        case average
    }

    struct Day: Sendable, Equatable {
        var start: Date
        var value: Double
    }

    /// The calendar that defines where each day starts and ends.
    public let calendar: Calendar
    public let aggregation: Aggregation
    let days: [DayKey: Day]
    /// Positive values in ascending order, used by the quantile level mapping.
    let sortedPositiveValues: [Double]

    /// Creates data from values keyed by date. Several dates on the same day are combined.
    public init(_ values: [Date: Double], calendar: Calendar = .current, aggregation: Aggregation = .sum) {
        self.init(pairs: values.map { ($0.key, $0.value) }, calendar: calendar, aggregation: aggregation)
    }

    /// Creates data from your own entries. Several entries on the same day are combined.
    public init<C: Collection>(
        _ entries: C,
        calendar: Calendar = .current,
        aggregation: Aggregation = .sum
    ) where C.Element: ActivityEntry {
        self.init(pairs: entries.map { ($0.date, $0.value) }, calendar: calendar, aggregation: aggregation)
    }

    init(pairs: [(Date, Double)], calendar: Calendar, aggregation: Aggregation) {
        struct Accumulator {
            var start: Date
            var value: Double
            var count: Int
            var latest: Date
        }

        var accumulators: [DayKey: Accumulator] = [:]
        for (date, rawValue) in pairs where rawValue.isFinite {
            let value = Swift.max(rawValue, 0)
            let key = DayKey(date, calendar: calendar)
            guard var current = accumulators[key] else {
                accumulators[key] = Accumulator(start: calendar.startOfDay(for: date), value: value, count: 1, latest: date)
                continue
            }
            switch aggregation {
            case .sum, .average:
                current.value += value
            case .max:
                current.value = Swift.max(current.value, value)
            case .last:
                // Equal dates keep the larger value so the result doesn't depend on input order.
                if date > current.latest || (date == current.latest && value > current.value) {
                    current.value = value
                }
            }
            current.count += 1
            current.latest = Swift.max(current.latest, date)
            accumulators[key] = current
        }

        var days: [DayKey: Day] = [:]
        days.reserveCapacity(accumulators.count)
        for (key, accumulator) in accumulators {
            let value = aggregation == .average ? accumulator.value / Double(accumulator.count) : accumulator.value
            days[key] = Day(start: accumulator.start, value: value)
        }

        self.calendar = calendar
        self.aggregation = aggregation
        self.days = days
        self.sortedPositiveValues = days.values.map(\.value).filter { $0 > 0 }.sorted()
    }

    /// The value of the day containing `date`, or `nil` if there is no data for that day.
    public func value(on date: Date) -> Double? {
        days[DayKey(date, calendar: calendar)]?.value
    }

    /// The number of days that have a value, including explicit zeros.
    public var count: Int { days.count }

    public var isEmpty: Bool { days.isEmpty }

    /// The largest daily value, or `0` when there is no data.
    public var maxValue: Double { sortedPositiveValues.last ?? 0 }

    func value(for key: DayKey) -> Double? {
        days[key]?.value
    }
}
