import SwiftUI
import SwiftUIActivityGrid

/// Streaks and totals from ActivityStatistics, next to the grid.
struct StreaksPage: View {
    private let values = SampleData.values()
    @State private var selection: Date?

    var body: some View {
        let stats = ActivityStatistics(ActivityGridData(values))
        ShowcasePage("Streaks", caption: "ActivityStatistics works with or without the view.") {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                StatTile(title: "Current streak", value: "\(stats.currentStreak?.length ?? 0)", unit: "days", symbol: "flame.fill", tint: .orange)
                StatTile(title: "Longest streak", value: "\(stats.longestStreak?.length ?? 0)", unit: "days", symbol: "trophy.fill", tint: .yellow)
                StatTile(title: "Active days", value: "\(stats.activeDays)", unit: "days", symbol: "calendar", tint: .green)
                StatTile(title: "Total", value: "\(Int(stats.total))", unit: "activities", symbol: "sum", tint: .blue)
            }

            VStack(alignment: .leading, spacing: 8) {
                ActivityGrid(values, range: .lastMonths(4), selection: $selection)
                    .activityGridDisplayMode(.fit)
                    .activityGridPalette(.orange)
                Text(selectionText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            CodeBox("""
            let data = ActivityGridData(values)
            let stats = ActivityStatistics(data)
            stats.currentStreak?.length  // \(stats.currentStreak?.length ?? 0)
            stats.longestStreak?.length  // \(stats.longestStreak?.length ?? 0)
            stats.activeDays             // \(stats.activeDays)
            stats.total                  // \(Int(stats.total))
            """)
        }
    }

    private var selectionText: String {
        guard let selection else { return "Tap a day to select it." }
        let value = values.first { Calendar.current.isDate($0.key, inSameDayAs: selection) }?.value ?? 0
        return "\(selection.formatted(date: .abbreviated, time: .omitted)): \(Int(value)) activities"
    }
}

struct StatTile: View {
    let title: String
    let value: String
    let unit: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.medium))
                .foregroundStyle(tint)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title.weight(.semibold))
                    .monospacedDigit()
                Text(unit)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
