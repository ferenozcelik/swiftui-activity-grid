import Foundation

/// A range of days arranged into week columns. Pure calendar maths, no SwiftUI.
struct GridLayout: Equatable, Sendable {
    struct Cell: Equatable, Sendable {
        let date: Date
        let key: DayKey
        let isInRange: Bool
        let isToday: Bool
        let isFuture: Bool
    }

    struct Week: Equatable, Sendable, Identifiable {
        /// The first day of the week, which may be outside the range.
        let start: Date
        let key: DayKey
        /// Always seven cells, starting on the calendar's first weekday.
        let cells: [Cell]
        /// The first day of the month whose label sits above this column, if any.
        let monthLabel: Date?

        var id: DayKey { key }
    }

    let weeks: [Week]
    let rangeStart: Date
    let rangeEnd: Date
    /// Calendar weekday numbers (1 = Sunday) in row order.
    let weekdays: [Int]

    var todayWeekIndex: Int? {
        weeks.firstIndex { week in week.cells.contains(where: \.isToday) }
    }
}

enum GridLayoutEngine {
    /// The fewest weeks between two month labels. Closer labels would overlap.
    static let minimumWeeksBetweenMonthLabels = 3

    static func layout(range: ActivityGridRange, calendar: Calendar, now: Date) -> GridLayout {
        let days = range.days(in: calendar, now: now)
        let startKey = DayKey(days.lowerBound, calendar: calendar)
        let endKey = DayKey(days.upperBound, calendar: calendar)
        let todayKey = DayKey(now, calendar: calendar)

        var weeks: [GridLayout.Week] = []
        var weekStart = calendar.startOfWeek(containing: days.lowerBound)
        var previousLabelIndex: Int?
        var firstLabelIsPartialMonth = false

        while DayKey(weekStart, calendar: calendar) <= endKey {
            var cells: [GridLayout.Cell] = []
            cells.reserveCapacity(7)
            var monthStart: Date?
            for offset in 0..<7 {
                // Always offset from the week start so a DST gap on one day doesn't shift the others.
                let date = calendar.startOfDay(for: calendar.addingDays(offset, to: weekStart))
                let key = DayKey(date, calendar: calendar)
                let isInRange = key >= startKey && key <= endKey
                cells.append(GridLayout.Cell(
                    date: date,
                    key: key,
                    isInRange: isInRange,
                    isToday: key == todayKey,
                    isFuture: key > todayKey
                ))
                if isInRange, monthStart == nil, calendar.component(.day, from: date) == 1 {
                    monthStart = date
                }
            }

            var monthLabel = monthStart
            if weeks.isEmpty, monthLabel == nil {
                // The range starts mid-month: label the first column with that month.
                monthLabel = calendar.dateInterval(of: .month, for: days.lowerBound)?.start
                firstLabelIsPartialMonth = true
            }
            if monthLabel != nil {
                if let previous = previousLabelIndex, weeks.count - previous < minimumWeeksBetweenMonthLabels {
                    // Too close to the previous label. A real month start wins over the partial first month.
                    if previous == 0, firstLabelIsPartialMonth {
                        weeks[0] = weeks[0].withoutMonthLabel()
                        previousLabelIndex = weeks.count
                    } else {
                        monthLabel = nil
                    }
                } else {
                    previousLabelIndex = weeks.count
                }
            }

            weeks.append(GridLayout.Week(
                start: weekStart,
                key: DayKey(weekStart, calendar: calendar),
                cells: cells,
                monthLabel: monthLabel
            ))
            weekStart = calendar.startOfDay(for: calendar.addingDays(7, to: weekStart))
        }

        let weekdays = (0..<7).map { (calendar.firstWeekday - 1 + $0) % 7 + 1 }
        return GridLayout(weeks: weeks, rangeStart: days.lowerBound, rangeEnd: days.upperBound, weekdays: weekdays)
    }
}

private extension GridLayout.Week {
    func withoutMonthLabel() -> GridLayout.Week {
        GridLayout.Week(start: start, key: key, cells: cells, monthLabel: nil)
    }
}
