import SwiftUI

/// One week of the grid: seven cells stacked top to bottom.
///
/// Sizes itself from the height it's offered, so the same view works with fixed
/// metrics (scrollable) and with cells scaled to fit.
struct WeekColumnView: View {
    let week: ResolvedGrid.Week
    let grid: ResolvedGrid
    let onTap: (ActivityDay) -> Void

    var body: some View {
        WeekColumnLayout(spacingRatio: grid.metrics.spacing / grid.metrics.cellSize) {
            ForEach(week.cells) { cell in
                DayCellView(cell: cell, grid: grid, onTap: onTap)
            }
        }
    }
}

/// Stacks seven cells vertically, keeping the gap proportional to the cell size.
struct WeekColumnLayout: Layout {
    let spacingRatio: CGFloat

    private func cellSize(forHeight height: CGFloat) -> CGFloat {
        height / (7 + 6 * spacingRatio)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let height = proposal.height ?? 7 * 12 + 6 * 12 * spacingRatio
        let cell = cellSize(forHeight: height)
        return CGSize(width: proposal.width ?? cell, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let cell = cellSize(forHeight: bounds.height)
        let step = cell * (1 + spacingRatio)
        for (row, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX, y: bounds.minY + CGFloat(row) * step),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: bounds.width, height: cell)
            )
        }
    }
}

/// One day: the style's cell, plus tapping and selection.
struct DayCellView: View {
    let cell: ResolvedGrid.Cell
    let grid: ResolvedGrid
    let onTap: (ActivityDay) -> Void

    var body: some View {
        if cell.isVisible {
            let isSelected = grid.selectedKey == cell.key
            DayCellContent(
                day: cell.day,
                color: grid.palette.color(forLevel: cell.day.level),
                isSelected: isSelected,
                palette: grid.palette
            )
            .equatable()
            .contentShape(Rectangle())
            .onTapGesture { onTap(cell.day) }
            .anchorPreference(key: SelectedCellAnchorKey.self, value: .bounds) { isSelected ? $0 : nil }
        } else {
            Color.clear
        }
    }

}

/// The style's view of a day. Equatable, so cells whose day, color and selection didn't
/// change are skipped when something else updates (like the selection moving).
struct DayCellContent: View, Equatable {
    let day: ActivityDay
    let color: Color
    let isSelected: Bool
    let palette: ActivityPalette

    @Environment(\.activityGridStyle) private var style

    var body: some View {
        style.makeCell(configuration: ActivityGridCellConfiguration(
            day: day,
            color: color,
            isSelected: isSelected,
            palette: palette
        ))
    }

    nonisolated static func == (lhs: DayCellContent, rhs: DayCellContent) -> Bool {
        lhs.day == rhs.day && lhs.color == rhs.color && lhs.isSelected == rhs.isSelected && lhs.palette == rhs.palette
    }
}
