import Foundation

/// How an ``ActivityGrid`` uses the space it gets.
public struct ActivityGridDisplayMode: Hashable, Sendable {
    /// Where a scrollable grid starts out.
    public enum InitialPosition: Hashable, Sendable {
        /// Scrolled to the week containing today, or to the end of the range if today isn't in it.
        case today
        /// Scrolled to the first week.
        case start
    }

    enum Kind: Hashable, Sendable {
        case scrollable(InitialPosition)
        case fit
    }

    let kind: Kind

    /// Cells keep their size from the style's metrics and the grid scrolls sideways when it
    /// doesn't fit. Columns are created lazily, so long ranges stay fast. The default.
    public static func scrollable(initialPosition: InitialPosition = .today) -> ActivityGridDisplayMode {
        ActivityGridDisplayMode(kind: .scrollable(initialPosition))
    }

    /// A scrollable grid that starts scrolled to today.
    public static let scrollable = ActivityGridDisplayMode.scrollable(initialPosition: .today)

    /// Every week is visible and the cells grow or shrink to fill the available width
    /// (and height, when the grid is given a fixed height). Doesn't scroll.
    public static let fit = ActivityGridDisplayMode(kind: .fit)
}
