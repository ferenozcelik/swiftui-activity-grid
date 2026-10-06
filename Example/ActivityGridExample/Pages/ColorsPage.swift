import SwiftUI
import SwiftUIActivityGrid

/// Every built-in palette, plus a gradient.
struct ColorsPage: View {
    private let values = SampleData.values()

    private let palettes: [(code: String, palette: ActivityPalette)] = [
        (".green", .green),
        (".blue", .blue),
        (".orange", .orange),
        (".purple", .purple),
        (".viridis", .viridis),
        (".monochrome", .monochrome),
        (".opacity(.pink)", .opacity(.pink)),
        (".opacity(.teal)", .opacity(.teal)),
    ]

    var body: some View {
        ShowcasePage("Colors", caption: "Built-in palettes. Each has light and dark colors.") {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], alignment: .leading, spacing: 16) {
                ForEach(palettes, id: \.code) { item in
                    Specimen(code: item.code) {
                        ActivityGrid(values, range: .lastWeeks(14))
                            .activityGridPalette(item.palette)
                    }
                }
            }
            .activityGridMonthLabels(.hidden)
            .activityGridWeekdayLabels(.hidden)
            .activityGridLegend(.hidden)

            Specimen("Gradient", code: ".gradient(from: .yellow, to: .red, levels: 6, …)") {
                ActivityGrid(values, range: .lastWeeks(28))
                    .activityGridPalette(.gradient(from: .yellow, to: .red, levels: 6, empty: .gray.opacity(0.18)))
                    .activityGridMonthLabels(.hidden)
            }
        }
        .activityGridDisplayMode(.fit)
    }
}
