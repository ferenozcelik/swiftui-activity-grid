import Foundation

/// A value recorded at a point in time, such as a workout, a commit or a journal entry.
///
/// Conform your own model type to pass it to ``ActivityGrid`` or ``ActivityGridData``
/// directly. Several entries on the same day are combined with an
/// ``ActivityGridData/Aggregation``.
///
/// ```swift
/// extension Workout: ActivityEntry {
///     var value: Double { Double(minutes) }
/// }
/// ```
public protocol ActivityEntry {
    /// When the activity happened. Only the calendar day matters.
    var date: Date { get }
    /// How much activity there was. Negative values are treated as zero.
    var value: Double { get }
}
