import SwiftUI

/// "Less ▢▢▢▢▢ More", drawn with the grid's own style so the swatches match the cells.
struct LegendView: View {
    let legend: ActivityGridLegend
    let grid: ResolvedGrid

    @Environment(\.activityGridStyle) private var style

    var body: some View {
        switch legend.kind {
        case .hidden:
            EmptyView()
        case .custom(let content):
            content(grid.palette)
        case .bottomTrailing(let less, let more):
            HStack(spacing: grid.metrics.spacing) {
                (less ?? Text(grid.text.less))
                    .padding(.trailing, grid.metrics.labelSpacing)
                ForEach(0...grid.palette.levelCount, id: \.self) { level in
                    swatch(level: level)
                        .frame(width: grid.metrics.cellSize, height: grid.metrics.cellSize)
                }
                (more ?? Text(grid.text.more))
                    .padding(.leading, grid.metrics.labelSpacing)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func swatch(level: Int) -> some View {
        let day = ActivityDay(
            date: grid.range.upperBound,
            value: nil,
            level: level,
            levelCount: grid.palette.levelCount
        )
        return style.makeCell(configuration: ActivityGridCellConfiguration(
            day: day,
            color: grid.palette.color(forLevel: level),
            isSelected: false,
            palette: grid.palette
        ))
    }
}
