import SwiftUI
import SwiftUIActivityGrid

/// Live controls for every option, with the matching code printed below the grid.
struct PlaygroundView: View {
    enum RangeOption: String, CaseIterable, Identifiable {
        case lastYear = "Last year"
        case lastMonths = "Last 6 months"
        case lastWeeks = "Last 12 weeks"
        case thisYear = "This year"
        case thisMonth = "This month"
        var id: Self { self }

        var range: ActivityGridRange {
            switch self {
            case .lastYear: .lastYear
            case .lastMonths: .lastMonths(6)
            case .lastWeeks: .lastWeeks(12)
            case .thisYear: .year(Calendar.current.component(.year, from: .now))
            case .thisMonth: .month(containing: .now)
            }
        }

        var code: String {
            switch self {
            case .lastYear: ".lastYear"
            case .lastMonths: ".lastMonths(6)"
            case .lastWeeks: ".lastWeeks(12)"
            case .thisYear: ".year(\(Calendar.current.component(.year, from: .now)))"
            case .thisMonth: ".month(containing: .now)"
            }
        }
    }

    enum StyleOption: String, CaseIterable, Identifiable {
        case automatic, github, rounded, circles, minimal
        var id: Self { self }

        var style: DefaultActivityGridStyle {
            switch self {
            case .automatic: .automatic
            case .github: .github
            case .rounded: .rounded
            case .circles: .circles
            case .minimal: .minimal
            }
        }
    }

    enum PaletteOption: String, CaseIterable, Identifiable {
        case green, blue, orange, purple, viridis, monochrome, gradient
        var id: Self { self }

        var palette: ActivityPalette {
            switch self {
            case .green: .green
            case .blue: .blue
            case .orange: .orange
            case .purple: .purple
            case .viridis: .viridis
            case .monochrome: .monochrome
            case .gradient: .gradient(from: .mint, to: .indigo, levels: 5, empty: .gray.opacity(0.15))
            }
        }

        var code: String {
            self == .gradient ? ".gradient(from: .mint, to: .indigo, levels: 5, empty: .gray.opacity(0.15))" : ".\(rawValue)"
        }
    }

    enum LevelOption: String, CaseIterable, Identifiable {
        case linear, quantile, thresholds
        var id: Self { self }

        var mapping: ActivityLevelMapping {
            switch self {
            case .linear: .linear
            case .quantile: .quantile
            case .thresholds: .thresholds([1, 4, 8, 11])
            }
        }

        var code: String { self == .thresholds ? ".thresholds([1, 4, 8, 11])" : ".\(rawValue)" }
    }

    enum WeekdayOption: String, CaseIterable, Identifiable {
        case alternate, all, hidden
        var id: Self { self }

        var visibility: WeekdayLabelVisibility {
            switch self {
            case .alternate: .alternate
            case .all: .all
            case .hidden: .hidden
            }
        }
    }

    enum FirstWeekdayOption: String, CaseIterable, Identifiable {
        case locale = "From locale", sunday = "Sunday", monday = "Monday"
        var id: Self { self }
    }

    enum LocaleOption: String, CaseIterable, Identifiable {
        case system = "System", english = "en_US", turkish = "tr_TR", japanese = "ja_JP", arabic = "ar_SA"
        var id: Self { self }
    }

    private let values = SampleData.values(days: 800)

    @State private var range = RangeOption.lastYear
    @State private var style = StyleOption.automatic
    @State private var palette = PaletteOption.green
    @State private var levels = LevelOption.linear
    @State private var fits = false
    @State private var showsMonths = true
    @State private var weekdays = WeekdayOption.alternate
    @State private var showsLegend = true
    @State private var firstWeekday = FirstWeekdayOption.locale
    @State private var localeOption = LocaleOption.system
    @State private var selection: Date?

    var body: some View {
        Form {
            Section {
                configuredGrid
                    .padding(.vertical, 8)
            }

            Section("Data") {
                Picker("Range", selection: $range) {
                    ForEach(RangeOption.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Levels", selection: $levels) {
                    ForEach(LevelOption.allCases) { Text($0.rawValue).tag($0) }
                }
            }

            Section("Look") {
                Picker("Style", selection: $style) {
                    ForEach(StyleOption.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Palette", selection: $palette) {
                    ForEach(PaletteOption.allCases) { Text($0.rawValue).tag($0) }
                }
                Toggle("Fit to width", isOn: $fits)
            }

            Section("Labels") {
                Toggle("Month labels", isOn: $showsMonths)
                Picker("Weekday labels", selection: $weekdays) {
                    ForEach(WeekdayOption.allCases) { Text($0.rawValue).tag($0) }
                }
                Toggle("Legend", isOn: $showsLegend)
            }

            Section("Calendar") {
                Picker("Locale", selection: $localeOption) {
                    ForEach(LocaleOption.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("First weekday", selection: $firstWeekday) {
                    ForEach(FirstWeekdayOption.allCases) { Text($0.rawValue).tag($0) }
                }
            }

            Section("Code") {
                Text(code)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("Playground")
    }

    @ViewBuilder
    private var configuredGrid: some View {
        let grid = ActivityGrid(values, range: range.range, selection: $selection)
            .activityGridStyle(style.style)
            .activityGridPalette(palette.palette)
            .activityGridLevels(levels.mapping)
            .activityGridDisplayMode(fits ? .fit : .scrollable)
            .activityGridMonthLabels(showsMonths ? .automatic : .hidden)
            .activityGridWeekdayLabels(weekdays.visibility)
            .activityGridLegend(showsLegend ? .automatic : .hidden)
            .environment(\.locale, locale)
            .environment(\.layoutDirection, localeOption == .arabic ? .rightToLeft : .leftToRight)

        switch firstWeekday {
        case .locale: grid
        case .sunday: grid.activityGridFirstWeekday(.sunday)
        case .monday: grid.activityGridFirstWeekday(.monday)
        }
    }

    private var locale: Locale {
        localeOption == .system ? .current : Locale(identifier: localeOption.rawValue)
    }

    /// The modifiers that differ from the defaults, as you would write them.
    private var code: String {
        var lines = ["ActivityGrid(values" + (range == .lastYear ? "" : ", range: \(range.code)") + ", selection: $selection)"]
        if style != .automatic { lines.append("    .activityGridStyle(.\(style.rawValue))") }
        if palette != .green { lines.append("    .activityGridPalette(\(palette.code))") }
        if levels != .linear { lines.append("    .activityGridLevels(\(levels.code))") }
        if fits { lines.append("    .activityGridDisplayMode(.fit)") }
        if !showsMonths { lines.append("    .activityGridMonthLabels(.hidden)") }
        if weekdays != .alternate { lines.append("    .activityGridWeekdayLabels(.\(weekdays.rawValue))") }
        if !showsLegend { lines.append("    .activityGridLegend(.hidden)") }
        if firstWeekday == .sunday { lines.append("    .activityGridFirstWeekday(.sunday)") }
        if firstWeekday == .monday { lines.append("    .activityGridFirstWeekday(.monday)") }
        if localeOption != .system { lines.append("    .environment(\\.locale, Locale(identifier: \"\(localeOption.rawValue)\"))") }
        return lines.joined(separator: "\n")
    }
}
