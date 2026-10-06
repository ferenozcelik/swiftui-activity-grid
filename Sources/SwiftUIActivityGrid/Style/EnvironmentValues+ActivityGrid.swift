import SwiftUI

// All configuration flows through the environment, like `buttonStyle`: set it once on a
// container and every grid inside picks it up, or set it on one grid only.

private struct StyleKey: EnvironmentKey {
    static var defaultValue: AnyActivityGridStyle { AnyActivityGridStyle(DefaultActivityGridStyle()) }
}

private struct PaletteKey: EnvironmentKey {
    static var defaultValue: ActivityPalette { .green }
}

private struct LevelMappingKey: EnvironmentKey {
    static var defaultValue: ActivityLevelMapping { .linear }
}

private struct CalendarKey: EnvironmentKey {
    static var defaultValue: Calendar? { nil }
}

private struct FirstWeekdayKey: EnvironmentKey {
    static var defaultValue: Locale.Weekday? { nil }
}

private struct MonthLabelsKey: EnvironmentKey {
    static var defaultValue: MonthLabelVisibility { .automatic }
}

private struct WeekdayLabelsKey: EnvironmentKey {
    static var defaultValue: WeekdayLabelVisibility { .alternate }
}

private struct LegendKey: EnvironmentKey {
    static var defaultValue: ActivityGridLegend { .automatic }
}

private struct DisplayModeKey: EnvironmentKey {
    static var defaultValue: ActivityGridDisplayMode { .scrollable }
}

private struct NowKey: EnvironmentKey {
    static var defaultValue: Date? { nil }
}

private struct TooltipKey: EnvironmentKey {
    static var defaultValue: ActivityGridTooltip { .automatic }
}

private struct TapActionKey: EnvironmentKey {
    static var defaultValue: (@MainActor @Sendable (ActivityDay) -> Void)? { nil }
}

private struct ValueFormatterKey: EnvironmentKey {
    static var defaultValue: (@MainActor @Sendable (Double) -> String)? { nil }
}

private struct DayLabelKey: EnvironmentKey {
    static var defaultValue: (@MainActor @Sendable (ActivityDay) -> Text)? { nil }
}

private struct DayValueKey: EnvironmentKey {
    static var defaultValue: (@MainActor @Sendable (ActivityDay) -> Text)? { nil }
}

private struct WeekLabelKey: EnvironmentKey {
    static var defaultValue: (@MainActor @Sendable (Date) -> Text)? { nil }
}

private struct SummaryKey: EnvironmentKey {
    static var defaultValue: (@MainActor @Sendable (ActivityStatistics) -> Text)? { nil }
}

extension EnvironmentValues {
    var activityGridStyle: AnyActivityGridStyle {
        get { self[StyleKey.self] }
        set { self[StyleKey.self] = newValue }
    }

    var activityGridPalette: ActivityPalette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }

    var activityGridLevelMapping: ActivityLevelMapping {
        get { self[LevelMappingKey.self] }
        set { self[LevelMappingKey.self] = newValue }
    }

    var activityGridCalendar: Calendar? {
        get { self[CalendarKey.self] }
        set { self[CalendarKey.self] = newValue }
    }

    var activityGridFirstWeekday: Locale.Weekday? {
        get { self[FirstWeekdayKey.self] }
        set { self[FirstWeekdayKey.self] = newValue }
    }

    var activityGridMonthLabels: MonthLabelVisibility {
        get { self[MonthLabelsKey.self] }
        set { self[MonthLabelsKey.self] = newValue }
    }

    var activityGridWeekdayLabels: WeekdayLabelVisibility {
        get { self[WeekdayLabelsKey.self] }
        set { self[WeekdayLabelsKey.self] = newValue }
    }

    var activityGridLegend: ActivityGridLegend {
        get { self[LegendKey.self] }
        set { self[LegendKey.self] = newValue }
    }

    var activityGridDisplayMode: ActivityGridDisplayMode {
        get { self[DisplayModeKey.self] }
        set { self[DisplayModeKey.self] = newValue }
    }

    var activityGridNow: Date? {
        get { self[NowKey.self] }
        set { self[NowKey.self] = newValue }
    }

    var activityGridTooltip: ActivityGridTooltip {
        get { self[TooltipKey.self] }
        set { self[TooltipKey.self] = newValue }
    }

    var activityGridTapAction: (@MainActor @Sendable (ActivityDay) -> Void)? {
        get { self[TapActionKey.self] }
        set { self[TapActionKey.self] = newValue }
    }

    var activityGridValueFormatter: (@MainActor @Sendable (Double) -> String)? {
        get { self[ValueFormatterKey.self] }
        set { self[ValueFormatterKey.self] = newValue }
    }

    var activityGridDayLabel: (@MainActor @Sendable (ActivityDay) -> Text)? {
        get { self[DayLabelKey.self] }
        set { self[DayLabelKey.self] = newValue }
    }

    var activityGridDayValue: (@MainActor @Sendable (ActivityDay) -> Text)? {
        get { self[DayValueKey.self] }
        set { self[DayValueKey.self] = newValue }
    }

    var activityGridWeekLabel: (@MainActor @Sendable (Date) -> Text)? {
        get { self[WeekLabelKey.self] }
        set { self[WeekLabelKey.self] = newValue }
    }

    var activityGridSummary: (@MainActor @Sendable (ActivityStatistics) -> Text)? {
        get { self[SummaryKey.self] }
        set { self[SummaryKey.self] = newValue }
    }
}

// MARK: - Modifiers

extension View {
    /// Sets the style that draws the day cells of grids in this view.
    ///
    /// ```swift
    /// .activityGridStyle(.circles)
    /// ```
    public func activityGridStyle<S: ActivityGridStyle>(_ style: S) -> some View {
        environment(\.activityGridStyle, AnyActivityGridStyle(style))
    }

    /// Sets the colors of grids in this view. The palette's level count sets the number of levels.
    public func activityGridPalette(_ palette: ActivityPalette) -> some View {
        environment(\.activityGridPalette, palette)
    }

    /// Sets how values are turned into color levels. The default is ``ActivityLevelMapping/linear``.
    public func activityGridLevels(_ mapping: ActivityLevelMapping) -> some View {
        environment(\.activityGridLevelMapping, mapping)
    }

    /// Sets the calendar that decides where days and weeks start, plus the language of the month
    /// and weekday names.
    ///
    /// Its time zone, first weekday and locale are all used. Without it, grids use
    /// `Calendar.current` with the `locale` from the environment.
    ///
    /// Grids created from an ``ActivityGridData`` always group days with the data's own
    /// calendar; they take only the locale and first weekday from this one.
    ///
    /// ```swift
    /// var calendar = Calendar(identifier: .gregorian)
    /// calendar.timeZone = .gmt          // days were recorded in UTC
    /// calendar.locale = Locale(identifier: "tr_TR")
    /// calendar.firstWeekday = 2         // Monday
    ///
    /// ActivityGrid(values)
    ///     .activityGridCalendar(calendar)
    /// ```
    public func activityGridCalendar(_ calendar: Calendar) -> some View {
        environment(\.activityGridCalendar, calendar)
    }

    /// Sets the first day of the week, overriding the calendar's `firstWeekday`.
    public func activityGridFirstWeekday(_ weekday: Locale.Weekday) -> some View {
        environment(\.activityGridFirstWeekday, weekday)
    }

    /// Shows, hides or replaces the month labels above the grid.
    public func activityGridMonthLabels(_ visibility: MonthLabelVisibility) -> some View {
        environment(\.activityGridMonthLabels, visibility)
    }

    /// Shows, hides or replaces the weekday labels beside the grid.
    public func activityGridWeekdayLabels(_ visibility: WeekdayLabelVisibility) -> some View {
        environment(\.activityGridWeekdayLabels, visibility)
    }

    /// Shows, hides or replaces the legend below the grid.
    public func activityGridLegend(_ legend: ActivityGridLegend) -> some View {
        environment(\.activityGridLegend, legend)
    }

    /// Sets whether grids scroll or shrink to fit. The default is ``ActivityGridDisplayMode/scrollable``.
    public func activityGridDisplayMode(_ mode: ActivityGridDisplayMode) -> some View {
        environment(\.activityGridDisplayMode, mode)
    }

    /// Pins the date grids treat as "now", for widgets, tests and previews.
    ///
    /// Without it, grids use the current date and refresh when the day or the time zone changes.
    public func activityGridNow(_ date: Date) -> some View {
        environment(\.activityGridNow, date)
    }

    /// Runs `action` when a day is tapped, after the selection is updated.
    public func onActivityDayTap(_ action: @escaping @MainActor @Sendable (ActivityDay) -> Void) -> some View {
        environment(\.activityGridTapAction, action)
    }

    /// Sets what appears when a day is selected.
    public func activityGridTooltip(_ tooltip: ActivityGridTooltip) -> some View {
        environment(\.activityGridTooltip, tooltip)
    }

    /// Replaces the tooltip content with your own view, shown in a bubble above the selected day.
    public func activityGridTooltip<V: View>(@ViewBuilder _ content: @escaping @MainActor @Sendable (ActivityDay) -> V) -> some View {
        environment(\.activityGridTooltip, .custom(content))
    }

    /// Sets how a value is written in the tooltip and read by VoiceOver, like "5 workouts" or "32 min".
    ///
    /// Days without a value still use the "No activity" text; replace the tooltip or the
    /// accessibility value to change that.
    public func activityGridValueFormatter(_ format: @escaping @MainActor @Sendable (Double) -> String) -> some View {
        environment(\.activityGridValueFormatter, format)
    }

    /// Replaces the VoiceOver label of each day. The default reads the full date,
    /// like "Tuesday, March 4, 2025".
    public func activityGridAccessibilityLabel(_ label: @escaping @MainActor @Sendable (ActivityDay) -> Text) -> some View {
        environment(\.activityGridDayLabel, label)
    }

    /// Replaces the VoiceOver value of each day. The default reads the value and level,
    /// like "5 activities, Level 3 of 4".
    public func activityGridAccessibilityValue(_ value: @escaping @MainActor @Sendable (ActivityDay) -> Text) -> some View {
        environment(\.activityGridDayValue, value)
    }

    /// Replaces the VoiceOver label of each week column. The closure gets the first day of the week.
    /// The default reads "Week of March 3".
    public func activityGridAccessibilityWeekLabel(_ label: @escaping @MainActor @Sendable (Date) -> Text) -> some View {
        environment(\.activityGridWeekLabel, label)
    }

    /// Replaces the VoiceOver summary of the whole grid. The default reads the date range,
    /// active days, current streak and longest streak.
    public func activityGridAccessibilitySummary(_ summary: @escaping @MainActor @Sendable (ActivityStatistics) -> Text) -> some View {
        environment(\.activityGridSummary, summary)
    }
}
