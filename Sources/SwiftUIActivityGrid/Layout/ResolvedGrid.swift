import SwiftUI

/// Everything the grid's subviews need for one update: the layout with values and levels
/// filled in, plus the resolved palette, metrics and texts.
struct ResolvedGrid {
    struct Cell: Identifiable {
        let day: ActivityDay
        let key: DayKey
        var id: DayKey { key }
        /// Cells outside the range and future days are not drawn and not tappable.
        var isVisible: Bool { day.isInRange && !day.isFuture }
    }

    struct Week: Identifiable {
        let id: DayKey
        let start: Date
        let cells: [Cell]
        let monthLabel: Date?
    }

    let weeks: [Week]
    /// Calendar weekday numbers (1 = Sunday) in row order.
    let weekdays: [Int]
    let range: ClosedRange<Date>
    let calendar: Calendar
    let palette: ActivityPalette
    let metrics: ActivityGridMetrics
    let text: ActivityGridText
    let selectedKey: DayKey?
    let todayWeekID: DayKey?

    init(
        data: ActivityGridData,
        range: ActivityGridRange,
        calendar: Calendar,
        now: Date,
        palette: ActivityPalette,
        mapping: ActivityLevelMapping,
        metrics: ActivityGridMetrics,
        selection: Date?
    ) {
        let layout = GridLayoutEngine.layout(range: range, calendar: calendar, now: now)
        let context = LevelContext(levelCount: palette.levelCount, data: data)

        weeks = layout.weeks.map { week in
            Week(
                id: week.key,
                start: week.start,
                cells: week.cells.map { cell in
                    let value = cell.isInRange ? data.value(for: cell.key) : nil
                    let day = ActivityDay(
                        date: cell.date,
                        value: value,
                        level: mapping.level(for: value, context: context),
                        levelCount: palette.levelCount,
                        isToday: cell.isToday,
                        isFuture: cell.isFuture,
                        isInRange: cell.isInRange
                    )
                    return Cell(day: day, key: cell.key)
                },
                monthLabel: week.monthLabel
            )
        }
        weekdays = layout.weekdays
        self.range = layout.rangeStart...layout.rangeEnd
        self.calendar = calendar
        self.palette = palette
        self.metrics = metrics
        self.text = ActivityGridText(calendar: calendar)
        selectedKey = selection.map { DayKey($0, calendar: calendar) }
        todayWeekID = layout.todayWeekIndex.map { layout.weeks[$0].key }
    }

    /// The selected day, if it is visible in this grid.
    var selectedDay: ActivityDay? {
        guard let selectedKey else { return nil }
        for week in weeks {
            if let cell = week.cells.first(where: { $0.key == selectedKey && $0.isVisible }) {
                return cell.day
            }
        }
        return nil
    }

    /// The week a scrollable grid starts at: today's week, or the last one when today isn't shown.
    var initialWeekID: DayKey? {
        todayWeekID ?? weeks.last?.id
    }
}
