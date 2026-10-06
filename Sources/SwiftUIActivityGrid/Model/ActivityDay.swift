import Foundation

/// One day shown in an ``ActivityGrid``.
///
/// Passed to styles, tap actions, tooltips and accessibility overrides.
public struct ActivityDay: Hashable, Identifiable, Sendable {
    /// The start of the day in the grid's calendar.
    public let date: Date
    /// The day's value. `nil` means there is no data, `0` means an explicit zero.
    public let value: Double?
    /// The intensity level, from `0` (no activity) up to ``levelCount``.
    public let level: Int
    /// The number of non-empty levels, which is the number of colors in the palette's `levels`.
    public let levelCount: Int
    /// `true` for the current day.
    public let isToday: Bool
    /// `true` for days after the current day.
    public let isFuture: Bool
    /// `false` for days that only fill up the first or last week of the grid.
    public let isInRange: Bool

    public var id: Date { date }

    public init(
        date: Date,
        value: Double?,
        level: Int,
        levelCount: Int,
        isToday: Bool = false,
        isFuture: Bool = false,
        isInRange: Bool = true
    ) {
        self.date = date
        self.value = value
        self.level = level
        self.levelCount = levelCount
        self.isToday = isToday
        self.isFuture = isFuture
        self.isInRange = isInRange
    }
}
