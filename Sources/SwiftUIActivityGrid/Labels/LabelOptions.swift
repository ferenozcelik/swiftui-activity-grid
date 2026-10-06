import SwiftUI

/// The month whose label is drawn above a week column.
public struct MonthLabelContext: Sendable {
    /// The first day of the month.
    public let date: Date
    /// The grid's calendar, with its locale and time zone.
    public let calendar: Calendar
    /// The month number in `calendar`.
    public var month: Int { calendar.component(.month, from: date) }
    /// The year number in `calendar`.
    public var year: Int { calendar.component(.year, from: date) }
}

/// Whether and how month labels are shown above the grid.
public struct MonthLabelVisibility: Sendable {
    enum Kind: Sendable {
        case automatic
        case hidden
        case custom(@MainActor @Sendable (MonthLabelContext) -> Text)
    }

    let kind: Kind

    /// Short month names in the grid's locale and calendar, like "Mar". The default.
    public static let automatic = MonthLabelVisibility(kind: .automatic)
    /// No month labels.
    public static let hidden = MonthLabelVisibility(kind: .hidden)
    /// Your own label for each month.
    ///
    /// ```swift
    /// .activityGridMonthLabels(.custom { month in
    ///     Text(month.date, format: .dateTime.month(.narrow))
    /// })
    /// ```
    public static func custom(_ label: @escaping @MainActor @Sendable (MonthLabelContext) -> Text) -> MonthLabelVisibility {
        MonthLabelVisibility(kind: .custom(label))
    }
}

/// Whether and how weekday labels are shown beside the grid.
public struct WeekdayLabelVisibility: Sendable {
    enum Kind: Sendable {
        case alternate
        case all
        case hidden
        case custom(@MainActor @Sendable (Locale.Weekday) -> Text?)
    }

    let kind: Kind

    /// Every other row, starting with the second (Mon, Wed, Fri when weeks start on Sunday). The default.
    public static let alternate = WeekdayLabelVisibility(kind: .alternate)
    /// A label on every row.
    public static let all = WeekdayLabelVisibility(kind: .all)
    /// No weekday labels.
    public static let hidden = WeekdayLabelVisibility(kind: .hidden)
    /// Your own label for each row. Return `nil` to leave a row without a label.
    public static func custom(_ label: @escaping @MainActor @Sendable (Locale.Weekday) -> Text?) -> WeekdayLabelVisibility {
        WeekdayLabelVisibility(kind: .custom(label))
    }
}

/// The legend that explains the colors, shown below the grid.
public struct ActivityGridLegend: Sendable {
    enum Kind: Sendable {
        case hidden
        case bottomTrailing(less: Text?, more: Text?)
        case custom(@MainActor @Sendable (ActivityPalette) -> AnyView)
    }

    let kind: Kind

    /// "Less ▢▢▢▢▢ More" at the bottom trailing corner, in the grid's language. The default.
    public static let automatic = ActivityGridLegend(kind: .bottomTrailing(less: nil, more: nil))
    /// No legend.
    public static let hidden = ActivityGridLegend(kind: .hidden)
    /// The default legend with your own words.
    public static func bottomTrailing(less: Text, more: Text) -> ActivityGridLegend {
        ActivityGridLegend(kind: .bottomTrailing(less: less, more: more))
    }
    /// Your own legend view. It gets the palette, resolved for the color scheme.
    public static func custom<V: View>(@ViewBuilder _ legend: @escaping @MainActor @Sendable (ActivityPalette) -> V) -> ActivityGridLegend {
        ActivityGridLegend(kind: .custom { AnyView(legend($0)) })
    }
}

/// What appears when a day is selected.
public struct ActivityGridTooltip: Sendable {
    enum Kind: Sendable {
        case automatic
        case hidden
        case custom(@MainActor @Sendable (ActivityDay) -> AnyView)
    }

    let kind: Kind

    /// A small bubble with the date and value, like "Mar 4, 2025 · 5 activities". The default.
    public static let automatic = ActivityGridTooltip(kind: .automatic)
    /// No tooltip. The selection is still shown and the binding still updates.
    public static let hidden = ActivityGridTooltip(kind: .hidden)
    /// Your own view, shown in a bubble above the selected day.
    public static func custom<V: View>(@ViewBuilder _ content: @escaping @MainActor @Sendable (ActivityDay) -> V) -> ActivityGridTooltip {
        ActivityGridTooltip(kind: .custom { AnyView(content($0)) })
    }
}

extension Locale.Weekday {
    /// Creates a weekday from a `Calendar` weekday number, where 1 is Sunday.
    init?(calendarWeekday: Int) {
        switch calendarWeekday {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil
        }
    }

    /// The `Calendar` weekday number, where 1 is Sunday.
    var calendarWeekday: Int {
        switch self {
        case .sunday: 1
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        @unknown default: 1
        }
    }
}
