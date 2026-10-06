import SwiftUI
import SwiftUIActivityGrid

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ExampleList()
            }
        }
    }
}

struct ExampleList: View {
    private let values = SampleData.values()

    var body: some View {
        List {
            Section {
                HeroCard(values: values)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section("Try it") {
                NavigationLink { PlaygroundView() } label: {
                    ExampleRow("Playground", detail: "Change options, see the code", symbol: "slider.horizontal.3", tint: .pink)
                }
            }

            Section("Showcase") {
                NavigationLink { StylesPage() } label: {
                    ExampleRow("Styles", detail: "Built-in cell styles", symbol: "square.grid.3x3.fill", tint: .green)
                }
                NavigationLink { ColorsPage() } label: {
                    ExampleRow("Colors", detail: "Palettes and gradients", symbol: "paintpalette.fill", tint: .orange)
                }
                NavigationLink { ShapesPage() } label: {
                    ExampleRow("Shapes and sizes", detail: "Shape, empty days, size, spacing", symbol: "circle.square.fill", tint: .blue)
                }
                NavigationLink { RangesPage() } label: {
                    ExampleRow("Ranges", detail: "Year, months, a month, custom", symbol: "calendar", tint: .red)
                }
                NavigationLink { LabelsPage() } label: {
                    ExampleRow("Labels and legend", detail: "Show, hide or replace them", symbol: "textformat", tint: .purple)
                }
                NavigationLink { OwnStylePage() } label: {
                    ExampleRow("Your own style", detail: "Custom cells and colors", symbol: "wand.and.stars", tint: .indigo)
                }
            }
        }
        .navigationTitle("ActivityGrid")
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
    }
}

/// The card at the top of the list.
private struct HeroCard: View {
    let values: [Date: Double]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("SwiftUIActivityGrid").font(.headline)
                Text("A heatmap of daily values for SwiftUI.").font(.subheadline).opacity(0.85)
            }
            ActivityGrid(values, range: .lastWeeks(20))
                .activityGridPalette(HabitCard.Palette.white)
                .activityGridDisplayMode(.fit)
                .activityGridMonthLabels(.hidden)
                .activityGridWeekdayLabels(.hidden)
                .activityGridLegend(.hidden)
        }
        .foregroundStyle(.white)
        .padding(16)
        .background(
            LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

private struct ExampleRow: View {
    let title: String
    let detail: String
    let symbol: String
    let tint: Color

    init(_ title: String, detail: String, symbol: String, tint: Color) {
        self.title = title
        self.detail = detail
        self.symbol = symbol
        self.tint = tint
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(tint.gradient, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
