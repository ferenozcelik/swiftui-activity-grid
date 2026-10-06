import SwiftUI
import SwiftUIActivityGrid

/// A tour of the built-in looks. Each card is one recipe from the README.
struct GalleryView: View {
    /// When set, only the card with this title is shown. Used to capture README screenshots.
    var only: String?
    private let values = SampleData.values()
    @State private var selection: Date?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                GalleryCard("Default", detail: "The last year, scrolled to today. Tap a day.") {
                    ActivityGrid(values, selection: $selection)
                    Text(selection.map { "Selected: \($0.formatted(date: .abbreviated, time: .omitted))" } ?? "Nothing selected")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                GalleryCard("Streaks", detail: "ActivityStatistics works without the view.") {
                    StreakSummary(values: values)
                }

                GalleryCard("Circles that fit", detail: "Six months, blue dots, sized to the width.") {
                    ActivityGrid(values, range: .lastMonths(6))
                        .activityGridStyle(.circles)
                        .activityGridPalette(.blue)
                        .activityGridDisplayMode(.fit)
                }

                GalleryCard("Gradient", detail: "Five levels blended from yellow to red.") {
                    ActivityGrid(values, range: .lastWeeks(20))
                        .activityGridPalette(.gradient(from: .yellow, to: .red, levels: 5, empty: .gray.opacity(0.15)))
                        .activityGridLevels(.quantile)
                        .activityGridStyle(.rounded)
                }

                GalleryCard("Colorblind-safe", detail: "Viridis with the minimal style.") {
                    ActivityGrid(values, range: .lastMonths(4))
                        .activityGridPalette(.viridis)
                        .activityGridStyle(.minimal)
                        .activityGridDisplayMode(.fit)
                }

                GalleryCard("This month", detail: "A calendar-like month with every weekday labeled.") {
                    ActivityGrid(values, range: .month(containing: .now))
                        .activityGridStyle(DefaultActivityGridStyle(shape: .roundedRectangle(cornerRadius: 6), metrics: .large))
                        .activityGridWeekdayLabels(.all)
                        .activityGridMonthLabels(.hidden)
                        .activityGridLegend(.hidden)
                        .activityGridDisplayMode(.fit)
                        .frame(maxWidth: 320)
                }

                GalleryCard("Your own style and words", detail: "A custom cell style, value formatter and legend text.") {
                    ActivityGrid(values, range: .lastWeeks(16))
                        .activityGridStyle(DotStyle())
                        .activityGridPalette(.opacity(.orange))
                        .activityGridValueFormatter { "\(Int($0)) min" }
                        .activityGridLegend(.bottomTrailing(less: Text("Rest"), more: Text("Training")))
                }

                GalleryCard("Türkçe", detail: "Labels and VoiceOver follow the locale; weeks start on Monday.") {
                    ActivityGrid(values, range: .lastMonths(5))
                        .activityGridPalette(.purple)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                }
            }
            .padding()
        }
        .navigationTitle(only ?? "Gallery")
        #if os(iOS)
        .navigationBarTitleDisplayMode(only == nil ? .large : .inline)
        #endif
        .environment(\.galleryFilter, only)
    }
}

private struct GalleryFilterKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var galleryFilter: String? {
        get { self[GalleryFilterKey.self] }
        set { self[GalleryFilterKey.self] = newValue }
    }
}

/// A cell style that draws bigger dots for busier days.
struct DotStyle: ActivityGridStyle {
    func makeCell(configuration: Configuration) -> some View {
        let fraction = configuration.levelCount > 0 ? Double(configuration.level) / Double(configuration.levelCount) : 0
        Circle()
            .fill(configuration.level == 0 ? configuration.palette.empty : configuration.color)
            .scaleEffect(configuration.level == 0 ? 0.35 : 0.5 + 0.5 * fraction)
            .overlay {
                if configuration.isSelected {
                    Circle().stroke(Color.primary, lineWidth: 1.5)
                }
            }
    }
}

struct StreakSummary: View {
    let values: [Date: Double]

    var body: some View {
        let stats = ActivityStatistics(ActivityGridData(values))
        HStack(spacing: 24) {
            stat("Current streak", value: "\(stats.currentStreak?.length ?? 0)")
            stat("Longest streak", value: "\(stats.longestStreak?.length ?? 0)")
            stat("Active days", value: "\(stats.activeDays)")
        }
    }

    private func stat(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.title2.weight(.semibold)).monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct GalleryCard<Content: View>: View {
    let title: String
    let detail: String
    @ViewBuilder let content: Content
    @Environment(\.galleryFilter) private var filter

    init(_ title: String, detail: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.detail = detail
        self.content = content()
    }

    var body: some View {
        if filter == nil || filter == title {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(detail).font(.subheadline).foregroundStyle(.secondary)
                }
                content
            }
        }
    }
}
