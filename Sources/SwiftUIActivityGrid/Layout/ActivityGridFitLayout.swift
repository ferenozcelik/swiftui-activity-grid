import SwiftUI

/// Every week visible, with the cells scaled to the space the grid gets.
struct FitGrid: View {
    let grid: ResolvedGrid
    let onTap: (ActivityDay) -> Void

    @Environment(\.activityGridMonthLabels) private var monthLabels
    @Environment(\.activityGridWeekdayLabels) private var weekdayLabels
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ActivityGridFitLayout(columnCount: grid.weeks.count, metrics: grid.metrics) {
            ForEach(0..<7, id: \.self) { row in
                if let label = WeekdayLabelsView.label(row: row, grid: grid, visibility: weekdayLabels, dynamicTypeSize: dynamicTypeSize) {
                    label.gridLabelStyle()
                        .layoutValue(key: GridSlotKey.self, value: .weekdayLabel(row))
                }
            }
            if case .hidden = monthLabels.kind {} else {
                ForEach(Array(grid.weeks.enumerated()), id: \.element.id) { index, week in
                    if week.monthLabel != nil {
                        MonthLabelView(monthStart: week.monthLabel, grid: grid)
                            .layoutValue(key: GridSlotKey.self, value: .monthLabel(index))
                    }
                }
            }
            ForEach(Array(grid.weeks.enumerated()), id: \.element.id) { index, week in
                WeekColumnView(week: week, grid: grid, onTap: onTap)
                    .layoutValue(key: GridSlotKey.self, value: .week(index))
            }
        }
    }
}

/// Where a subview of ``ActivityGridFitLayout`` goes.
enum GridSlot: Equatable {
    case week(Int)
    case monthLabel(Int)
    case weekdayLabel(Int)
}

struct GridSlotKey: LayoutValueKey {
    static var defaultValue: GridSlot { .week(0) }
}

/// Lays out week columns, month labels and weekday labels so all weeks fit the proposed width
/// (and height, if one is proposed). Not lazy, so it suits widgets and ranges up to a year or two.
struct ActivityGridFitLayout: Layout {
    let columnCount: Int
    let metrics: ActivityGridMetrics

    struct Cache {
        var headerHeight: CGFloat
        var leadingWidth: CGFloat
    }

    private var spacingRatio: CGFloat { metrics.spacing / metrics.cellSize }

    func makeCache(subviews: Subviews) -> Cache {
        var header: CGFloat = 0
        var leading: CGFloat = 0
        for subview in subviews {
            switch subview[GridSlotKey.self] {
            case .monthLabel:
                header = max(header, subview.sizeThatFits(.unspecified).height)
            case .weekdayLabel:
                leading = max(leading, subview.sizeThatFits(.unspecified).width)
            case .week:
                break
            }
        }
        return Cache(
            headerHeight: header > 0 ? header + metrics.labelSpacing : 0,
            leadingWidth: leading > 0 ? leading + metrics.labelSpacing : 0
        )
    }

    private func cellSize(for proposal: ProposedViewSize, cache: Cache) -> CGFloat {
        let columns = CGFloat(max(columnCount, 1))
        var size = metrics.cellSize
        if let width = proposal.width, width.isFinite {
            size = (width - cache.leadingWidth) / (columns + (columns - 1) * spacingRatio)
        }
        if let height = proposal.height, height.isFinite {
            size = min(size, (height - cache.headerHeight) / (7 + 6 * spacingRatio))
        }
        return max(size, 1)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let cell = cellSize(for: proposal, cache: cache)
        let columns = CGFloat(max(columnCount, 1))
        return CGSize(
            width: cache.leadingWidth + columns * cell + (columns - 1) * cell * spacingRatio,
            height: cache.headerHeight + 7 * cell + 6 * cell * spacingRatio
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        let cell = cellSize(for: ProposedViewSize(bounds.size), cache: cache)
        let step = cell * (1 + spacingRatio)
        let gridTop = bounds.minY + cache.headerHeight
        let gridLeading = bounds.minX + cache.leadingWidth

        for subview in subviews {
            switch subview[GridSlotKey.self] {
            case .week(let index):
                subview.place(
                    at: CGPoint(x: gridLeading + CGFloat(index) * step, y: gridTop),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: cell, height: 7 * cell + 6 * cell * spacingRatio)
                )
            case .monthLabel(let index):
                subview.place(
                    at: CGPoint(x: gridLeading + CGFloat(index) * step, y: bounds.minY),
                    anchor: .topLeading,
                    proposal: .unspecified
                )
            case .weekdayLabel(let row):
                subview.place(
                    at: CGPoint(x: gridLeading - metrics.labelSpacing, y: gridTop + CGFloat(row) * step + cell / 2),
                    anchor: .trailing,
                    proposal: .unspecified
                )
            }
        }
    }
}
