import SwiftUI
import SwiftUIActivityGrid

/// Cell shape, empty days, size and spacing of the built-in style.
struct ShapesPage: View {
    private let values = SampleData.values()

    var body: some View {
        ShowcasePage("Shapes and sizes", caption: "Options of DefaultActivityGridStyle.") {
            row("shape:") {
                tile(".square", DefaultActivityGridStyle(shape: .square))
                tile(".roundedRectangle(\ncornerRadius: 5)", DefaultActivityGridStyle(shape: .roundedRectangle(cornerRadius: 5)))
                tile(".circle", DefaultActivityGridStyle(shape: .circle))
            }
            row("emptyCell:") {
                tile(".filled", DefaultActivityGridStyle(emptyCell: .filled))
                tile(".outlined(\nlineWidth: 1)", DefaultActivityGridStyle(emptyCell: .outlined(lineWidth: 1)))
                tile(".hidden", DefaultActivityGridStyle(emptyCell: .hidden))
            }
            row("metrics:") {
                sizeTile(".small", .small)
                sizeTile(".standard", .standard)
                sizeTile(".large", .large)
            }
            row("metrics:", title: "ActivityGridMetrics(cellSize: 12, spacing:)") {
                tile("spacing: 0", DefaultActivityGridStyle(metrics: ActivityGridMetrics(cellSize: 12, spacing: 0)))
                tile("spacing: 3", DefaultActivityGridStyle(metrics: ActivityGridMetrics(cellSize: 12, spacing: 3)))
                tile("spacing: 6", DefaultActivityGridStyle(metrics: ActivityGridMetrics(cellSize: 12, spacing: 6)))
            }
        }
        .activityGridMonthLabels(.hidden)
        .activityGridWeekdayLabels(.hidden)
        .activityGridLegend(.hidden)
        .activityGridPalette(.blue)
    }

    private func row<Content: View>(_ parameter: String, title: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title ?? "DefaultActivityGridStyle(\(parameter))")
                .font(.caption.monospaced().weight(.semibold))
            HStack(alignment: .bottom, spacing: 12) {
                content()
            }
        }
    }

    /// A small grid that fits its box.
    private func tile(_ code: String, _ style: DefaultActivityGridStyle) -> some View {
        VStack(spacing: 6) {
            ActivityGrid(values, range: .lastWeeks(8))
                .activityGridStyle(style)
                .activityGridDisplayMode(.fit)
                .frame(height: 80)
            Text(code)
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(height: 28, alignment: .top)
        }
        .frame(maxWidth: .infinity)
    }

    /// A small grid at the real size of `metrics`.
    private func sizeTile(_ code: String, _ metrics: ActivityGridMetrics) -> some View {
        VStack(spacing: 6) {
            ActivityGrid(values, range: .lastWeeks(5))
                .activityGridStyle(DefaultActivityGridStyle(metrics: metrics))
                .fixedSize()
            CodeLabel(code)
                .frame(height: 26, alignment: .top)
        }
        .frame(maxWidth: .infinity)
    }
}
