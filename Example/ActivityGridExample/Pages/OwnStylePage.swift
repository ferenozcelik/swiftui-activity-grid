import SwiftUI
import SwiftUIActivityGrid

/// A custom palette inside an app card, and two custom cell styles.
struct OwnStylePage: View {
    private let values = SampleData.values()

    var body: some View {
        ShowcasePage("Your own style", caption: "Your colors, your cells, your words.") {
            Specimen("Your colors", code: "ActivityPalette(empty: …, levels: […])") {
                HabitCard(values: values)
            }

            Specimen("Dots", code: ".activityGridStyle(DotStyle())") {
                ActivityGrid(values, range: .lastWeeks(32))
                    .activityGridStyle(DotStyle())
                    .activityGridPalette(.opacity(.orange))
                    .activityGridValueFormatter { "\(Int($0)) min" }
                    .activityGridLegend(.bottomTrailing(less: Text("Rest"), more: Text("Training")))
            }

            Specimen("Bars", code: ".activityGridStyle(BarStyle())") {
                ActivityGrid(values, range: .lastWeeks(32))
                    .activityGridStyle(BarStyle())
                    .activityGridPalette(.opacity(.teal))
                    .activityGridMonthLabels(.hidden)
                    .activityGridLegend(.hidden)
            }

            CodeBox("""
            struct DotStyle: ActivityGridStyle {
              func makeCell(configuration c: Configuration)
                -> some View {
                Circle()
                  .fill(c.color)
                  .scaleEffect(0.4 + 0.15 * Double(c.level))
              }
            }
            """, font: .caption2.monospaced())
        }
        .activityGridDisplayMode(.fit)
    }
}

/// A card that looks like part of a habit app: white cells on the app's own colors.
struct HabitCard: View {
    let values: [Date: Double]

    enum Palette {
        /// White cells for a colored background.
        static let white = ActivityPalette(
            empty: .white.opacity(0.14),
            levels: [.white.opacity(0.35), .white.opacity(0.55), .white.opacity(0.78), .white]
        )
    }

    var body: some View {
        let stats = ActivityStatistics(ActivityGridData(values))
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "book.fill")
                    .font(.headline)
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.2), in: Circle())
                VStack(alignment: .leading, spacing: 1) {
                    Text("Reading").font(.headline)
                    Text("\(stats.currentStreak?.length ?? 0) day streak").font(.caption).opacity(0.8)
                }
                Spacer()
            }
            ActivityGrid(values, range: .lastWeeks(26))
                .activityGridPalette(Palette.white)
                .activityGridStyle(.rounded)
                .activityGridMonthLabels(.hidden)
                .activityGridWeekdayLabels(.hidden)
                .activityGridLegend(.hidden)
        }
        .foregroundStyle(.white)
        .padding(16)
        .background(
            LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

/// Bigger dots for busier days.
struct DotStyle: ActivityGridStyle {
    func makeCell(configuration c: Configuration) -> some View {
        Circle()
            .fill(c.color)
            .scaleEffect(0.4 + 0.15 * Double(c.level))
            .overlay {
                if c.isSelected {
                    Circle().stroke(Color.primary, lineWidth: 1.5)
                }
            }
    }
}

/// A bar for each day, taller for busier days.
struct BarStyle: ActivityGridStyle {
    func makeCell(configuration: Configuration) -> some View {
        let fraction = configuration.levelCount > 0 ? Double(configuration.level) / Double(configuration.levelCount) : 0
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                    .fill(configuration.level == 0 ? configuration.palette.empty : configuration.color)
                    .frame(height: configuration.level == 0 ? 2 : proxy.size.height * (0.3 + 0.7 * fraction))
            }
            .overlay {
                if configuration.isSelected {
                    RoundedRectangle(cornerRadius: 2).stroke(Color.primary, lineWidth: 1.5)
                }
            }
        }
    }
}
