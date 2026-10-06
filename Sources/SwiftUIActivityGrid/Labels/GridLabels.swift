import SwiftUI

/// The month label above one week column, or an empty header of the same height.
struct MonthLabelView: View {
    let monthStart: Date?
    let grid: ResolvedGrid

    @Environment(\.activityGridMonthLabels) private var visibility

    var body: some View {
        if let monthStart {
            label(for: monthStart).gridLabelStyle()
        } else {
            Color.clear
        }
    }

    private func label(for monthStart: Date) -> Text {
        switch visibility.kind {
        case .custom(let label):
            label(MonthLabelContext(date: monthStart, calendar: grid.calendar))
        case .automatic, .hidden:
            Text(grid.text.shortMonth(monthStart))
        }
    }
}

/// Weekday names beside the rows of a scrollable grid.
struct WeekdayLabelsView: View {
    let grid: ResolvedGrid
    let rowHeight: CGFloat
    let spacing: CGFloat
    /// The height of the month label row above the cells, or `nil` without month labels.
    let headerHeight: CGFloat?

    @Environment(\.activityGridWeekdayLabels) private var visibility
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if case .hidden = visibility.kind {
            EmptyView()
        } else {
            VStack(alignment: .trailing, spacing: grid.metrics.labelSpacing) {
                if let headerHeight {
                    Color.clear.frame(width: 0, height: headerHeight)
                }
                VStack(alignment: .trailing, spacing: spacing) {
                    ForEach(0..<7, id: \.self) { row in
                        Group {
                            if let label = Self.label(row: row, grid: grid, visibility: visibility, dynamicTypeSize: dynamicTypeSize) {
                                label.gridLabelStyle()
                            } else {
                                Color.clear.frame(width: 0)
                            }
                        }
                        .frame(height: rowHeight)
                    }
                }
            }
        }
    }

    /// The label of `row`, or `nil` when the row has none.
    @MainActor
    static func label(row: Int, grid: ResolvedGrid, visibility: WeekdayLabelVisibility, dynamicTypeSize: DynamicTypeSize) -> Text? {
        let weekday = grid.weekdays[row]
        switch visibility.kind {
        case .hidden:
            return nil
        case .custom(let label):
            return Locale.Weekday(calendarWeekday: weekday).flatMap(label)
        case .alternate, .all:
            // Every row is too crowded at accessibility text sizes.
            let showsAll = visibility.kind.isAll && !dynamicTypeSize.isAccessibilitySize
            guard showsAll || row % 2 == 1 else { return nil }
            return Text(grid.text.shortWeekdaySymbols[weekday - 1])
        }
    }
}

extension Text {
    /// The look shared by month and weekday labels.
    func gridLabelStyle() -> some View {
        font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .fixedSize()
    }
}

private extension WeekdayLabelVisibility.Kind {
    var isAll: Bool {
        if case .all = self { return true }
        return false
    }
}
