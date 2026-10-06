import Foundation

/// What a level mapping knows about the data when it picks a level.
public struct LevelContext: Sendable {
    /// The number of non-empty levels. Levels go from `1` through `levelCount`; `0` means no activity.
    public let levelCount: Int
    /// The largest daily value in the data, or `0` when there is no data.
    public let maxValue: Double
    let sortedPositiveValues: [Double]

    /// Creates a context for `data` with `levelCount` non-empty levels.
    public init(levelCount: Int, data: ActivityGridData) {
        self.init(levelCount: levelCount, sortedPositiveValues: data.sortedPositiveValues)
    }

    init(levelCount: Int, sortedPositiveValues: [Double]) {
        self.levelCount = max(levelCount, 1)
        self.maxValue = sortedPositiveValues.last ?? 0
        self.sortedPositiveValues = sortedPositiveValues
    }
}

/// Turns a day's value into a color level.
///
/// The number of levels always comes from the palette (the count of its `levels`
/// colors), so the colors and the mapping never disagree. Whatever the mapping:
/// - no value and `0` are always level `0`;
/// - any positive value is at least level `1`, so a day with activity never looks empty;
/// - results are clamped to `0...levelCount`.
public struct ActivityLevelMapping: Sendable {
    private enum Kind: Sendable {
        case linear(max: Double?)
        case quantile
        case thresholds([Double])
        case custom(@Sendable (Double, LevelContext) -> Int)
    }

    private let kind: Kind

    /// Splits `0...max` into equal steps. The default.
    ///
    /// - Parameter max: The value that gets the top level. `nil` uses the largest value in the data.
    public static func linear(max: Double? = nil) -> ActivityLevelMapping {
        ActivityLevelMapping(kind: .linear(max: max))
    }

    /// Equal steps up to the largest value in the data.
    public static var linear: ActivityLevelMapping { .linear(max: nil) }

    /// Spreads the non-zero values evenly over the levels, so a few very large days don't wash out the rest.
    ///
    /// A value's level follows its rank among the non-zero values. Equal values always share a level.
    public static var quantile: ActivityLevelMapping {
        ActivityLevelMapping(kind: .quantile)
    }

    /// Fixed lower bounds for each level, in ascending order.
    ///
    /// With `[1, 5, 10, 20]`, values from 5 up to (not including) 10 are level 2
    /// and values of 20 or more are level 4. Positive values below the first
    /// threshold still get level 1.
    public static func thresholds(_ thresholds: [Double]) -> ActivityLevelMapping {
        ActivityLevelMapping(kind: .thresholds(thresholds.sorted()))
    }

    /// Your own rule. It is only called for positive values, and its result is clamped to `1...levelCount`.
    public static func custom(_ level: @escaping @Sendable (Double, LevelContext) -> Int) -> ActivityLevelMapping {
        ActivityLevelMapping(kind: .custom(level))
    }

    /// The level of `value`, from `0` through `context.levelCount`.
    public func level(for value: Double?, context: LevelContext) -> Int {
        guard let value, value.isFinite, value > 0 else { return 0 }
        let count = context.levelCount
        let raw: Int
        switch kind {
        case .linear(let max):
            let upper = max ?? context.maxValue
            raw = upper > 0 ? Int((value / upper * Double(count)).rounded(.up)) : count
        case .quantile:
            let values = context.sortedPositiveValues
            guard !values.isEmpty else { return count }
            // The share of values at or below this one (the empirical CDF).
            let atOrBelow = values.partitioningIndex { $0 > value }
            raw = Int((Double(atOrBelow) / Double(values.count) * Double(count)).rounded(.up))
        case .thresholds(let thresholds):
            raw = thresholds.filter { value >= $0 }.count
        case .custom(let level):
            raw = level(value, context)
        }
        return Swift.min(Swift.max(raw, 1), count)
    }
}

extension Array where Element: Comparable {
    /// The index of the first element matching `predicate`, assuming the array is partitioned by it.
    func partitioningIndex(where predicate: (Element) -> Bool) -> Int {
        var low = 0
        var high = count
        while low < high {
            let mid = (low + high) / 2
            if predicate(self[mid]) {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }
}
