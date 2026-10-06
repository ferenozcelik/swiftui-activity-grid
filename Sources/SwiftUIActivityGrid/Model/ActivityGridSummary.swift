import Foundation

/// What the grid shows, for your own VoiceOver summary.
///
/// Passed to ``SwiftUI/View/activityGridAccessibilitySummary(_:)``.
public struct ActivityGridSummary: Hashable, Sendable {
    /// The first and last day the grid shows.
    public let range: ClosedRange<Date>
    /// The number of days in `range` with a value above zero.
    public let activeDays: Int

    public init(range: ClosedRange<Date>, activeDays: Int) {
        self.range = range
        self.activeDays = activeDays
    }
}
