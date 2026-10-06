import Combine
import SwiftUI

/// A heatmap of daily values, like the contribution graph on a GitHub profile.
///
/// Pass your values and, optionally, a range. Everything else is set with
/// `activityGrid…` modifiers, either on the grid or once on a container.
///
/// ```swift
/// ActivityGrid(workoutMinutesByDate, range: .lastYear, selection: $selectedDay)
///     .activityGridPalette(.blue)
///     .activityGridStyle(.rounded)
/// ```
///
/// The grid stores nothing and makes no network calls; it only draws what you pass in.
public struct ActivityGrid: View {
    private enum Source {
        case pairs([(Date, Double)])
        case data(ActivityGridData)
    }

    private let source: Source
    private let range: ActivityGridRange
    private let selection: Binding<Date?>?

    @State private var internalSelection: Date?
    @State private var systemNow = Date()

    @Environment(\.activityGridStyle) private var style
    @Environment(\.activityGridPalette) private var palette
    @Environment(\.activityGridLevelMapping) private var levelMapping
    @Environment(\.activityGridCalendar) private var hostCalendar
    @Environment(\.activityGridFirstWeekday) private var firstWeekday
    @Environment(\.activityGridDisplayMode) private var displayMode
    @Environment(\.activityGridLegend) private var legend
    @Environment(\.activityGridTooltip) private var tooltip
    @Environment(\.activityGridNow) private var pinnedNow
    @Environment(\.activityGridTapAction) private var tapAction
    @Environment(\.activityGridSummary) private var summary
    @Environment(\.activityGridValueFormatter) private var valueFormatter
    @Environment(\.locale) private var locale
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Creates a grid from values keyed by date.
    ///
    /// Several dates on the same day are added up. To combine them differently, or to avoid
    /// rebuilding the data on every update when you have years of it, pass an ``ActivityGridData``.
    ///
    /// - Parameters:
    ///   - values: The values. Only the calendar day of each date matters.
    ///   - range: The days to show. The default is about the last year.
    ///   - selection: The selected day, at the start of its day. Tapping a day selects it, tapping it again clears it.
    public init(_ values: [Date: Double], range: ActivityGridRange = .lastYear, selection: Binding<Date?>? = nil) {
        self.source = .pairs(values.map { ($0.key, $0.value) })
        self.range = range
        self.selection = selection
    }

    /// Creates a grid from your own entries. Several entries on the same day are added up.
    public init<C: Collection>(
        _ entries: C,
        range: ActivityGridRange = .lastYear,
        selection: Binding<Date?>? = nil
    ) where C.Element: ActivityEntry {
        self.source = .pairs(entries.map { ($0.date, $0.value) })
        self.range = range
        self.selection = selection
    }

    /// Creates a grid from data you built once and keep, which is the fastest way to show a lot of data.
    ///
    /// Days are grouped with the data's own calendar.
    public init(_ data: ActivityGridData, range: ActivityGridRange = .lastYear, selection: Binding<Date?>? = nil) {
        self.source = .data(data)
        self.range = range
        self.selection = selection
    }

    public var body: some View {
        let grid = resolve()
        VStack(alignment: .leading, spacing: grid.metrics.labelSpacing) {
            switch displayMode.kind {
            case .scrollable(let initialPosition):
                ScrollableGrid(grid: grid, initialPosition: initialPosition) { toggle($0, in: grid) }
            case .fit:
                FitGrid(grid: grid) { toggle($0, in: grid) }
            }
            LegendView(legend: legend, grid: grid)
        }
        .overlayPreferenceValue(SelectedCellAnchorKey.self) { anchor in
            if let anchor, let day = grid.selectedDay {
                TooltipOverlay(anchor: anchor, day: day, tooltip: tooltip, grid: grid, valueFormatter: valueFormatter)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(summaryText(for: grid))
        .onReceive(dayChanges) { _ in systemNow = Date() }
    }

    // MARK: - Resolving

    private func resolve() -> ResolvedGrid {
        let calendar: Calendar
        let data: ActivityGridData
        switch source {
        case .pairs(let pairs):
            calendar = resolvedCalendar(base: hostCalendar ?? .current, hostDecidesLocale: hostCalendar != nil)
            data = ActivityGridData(pairs: pairs, calendar: calendar, aggregation: .sum)
        case .data(let prebuilt):
            data = prebuilt
            var base = prebuilt.calendar
            if let hostCalendar {
                base.locale = hostCalendar.locale
                base.firstWeekday = hostCalendar.firstWeekday
            }
            calendar = resolvedCalendar(base: base, hostDecidesLocale: hostCalendar != nil)
        }

        let metrics = style.metrics(in: ActivityGridStyleContext(displayMode: displayMode, dynamicTypeSize: dynamicTypeSize))
        return ResolvedGrid(
            data: data,
            range: range,
            calendar: calendar,
            now: pinnedNow ?? systemNow,
            palette: palette.resolved(for: colorScheme),
            mapping: levelMapping,
            metrics: metrics,
            selection: selection?.wrappedValue ?? (selection == nil ? internalSelection : nil)
        )
    }

    /// Applies the locale fallback and the first weekday override.
    private func resolvedCalendar(base: Calendar, hostDecidesLocale: Bool) -> Calendar {
        var calendar = base
        if !hostDecidesLocale {
            // Without a host calendar, labels follow the SwiftUI locale. Unless the calendar's first
            // weekday was set explicitly, it follows that locale too (Monday for Turkish).
            calendar.locale = locale
        }
        if let firstWeekday {
            calendar.firstWeekday = firstWeekday.calendarWeekday
        }
        return calendar
    }

    // MARK: - Interaction

    private func toggle(_ day: ActivityDay, in grid: ResolvedGrid) {
        let isSelected = grid.selectedKey == DayKey(day.date, calendar: grid.calendar)
        let newValue = isSelected ? nil : day.date
        if let selection {
            selection.wrappedValue = newValue
        } else {
            internalSelection = newValue
        }
        tapAction?(day)
    }

    // MARK: - Accessibility

    private func summaryText(for grid: ResolvedGrid) -> Text {
        if let summary {
            return summary(grid.statistics)
        }
        return Text(grid.text.summary(range: grid.range, activeDays: grid.activeDaysInRange, statistics: grid.statistics))
    }

    /// Fires when the day changes or the device moves to another time zone, so "today" stays right.
    private var dayChanges: AnyPublisher<Notification, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: .NSCalendarDayChanged),
            NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)
        )
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
