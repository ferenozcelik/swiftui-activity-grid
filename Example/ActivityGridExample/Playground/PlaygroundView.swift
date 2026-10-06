import SwiftUI
import SwiftUIActivityGrid
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Live controls for the main options. The grid and the matching code stay on top.
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
        case automatic, squares, rounded, circles, minimal
        var id: Self { self }

        var style: DefaultActivityGridStyle {
            switch self {
            case .automatic: .automatic
            case .squares: .squares
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
            case .gradient: .gradient(from: .mint, to: .indigo, levels: 5, empty: .gray.opacity(0.18))
            }
        }

        var code: String {
            self == .gradient ? ".gradient(from: .mint, to: .indigo,\n                               levels: 5, empty: .gray.opacity(0.18))" : ".\(rawValue)"
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
        case calendar = "From calendar", sunday = "Sunday", monday = "Monday"
        var id: Self { self }
    }

    private let values = SampleData.values(days: 800)

    @State private var range = RangeOption.lastMonths
    @State private var style = StyleOption.rounded
    @State private var palette = PaletteOption.blue
    @State private var levels = LevelOption.linear
    @State private var fits = true
    @State private var showsMonths = true
    @State private var weekdays = WeekdayOption.alternate
    @State private var showsLegend = true
    @State private var firstWeekday = FirstWeekdayOption.calendar
    @State private var selection: Date?
    @State private var copied = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                // A short range that fits the width would get very tall cells. Cap its height.
                if fits, range == .thisMonth || range == .lastWeeks {
                    configuredGrid
                        .frame(height: 180, alignment: .topLeading)
                } else {
                    configuredGrid
                }
                codeBox
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 14)
            #if os(iOS)
            .background(Color(uiColor: .systemBackground))
            #endif

            Divider()

            Form {
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
                    Picker("First weekday", selection: $firstWeekday) {
                        ForEach(FirstWeekdayOption.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Toggle("Legend", isOn: $showsLegend)
                }
            }
            #if os(macOS)
            .formStyle(.grouped)
            #endif
        }
        .navigationTitle("Playground")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var codeBox: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                GroupHeading("Code")
                Spacer()
                Button {
                    copy(code)
                } label: {
                    Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.borderless)
            }
            CodeBox(code)
                .textSelection(.enabled)
        }
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

        switch firstWeekday {
        case .calendar: grid
        case .sunday: grid.activityGridFirstWeekday(.sunday)
        case .monday: grid.activityGridFirstWeekday(.monday)
        }
    }

    /// The modifiers that differ from the defaults, as you would write them.
    private var code: String {
        var lines = ["ActivityGrid(values" + (range == .lastYear ? "" : ", range: \(range.code)") + ")"]
        if style != .automatic { lines.append("    .activityGridStyle(.\(style.rawValue))") }
        if palette != .green { lines.append("    .activityGridPalette(\(palette.code))") }
        if levels != .linear { lines.append("    .activityGridLevels(\(levels.code))") }
        if fits { lines.append("    .activityGridDisplayMode(.fit)") }
        if !showsMonths { lines.append("    .activityGridMonthLabels(.hidden)") }
        if weekdays != .alternate { lines.append("    .activityGridWeekdayLabels(.\(weekdays.rawValue))") }
        if firstWeekday == .sunday { lines.append("    .activityGridFirstWeekday(.sunday)") }
        if firstWeekday == .monday { lines.append("    .activityGridFirstWeekday(.monday)") }
        if !showsLegend { lines.append("    .activityGridLegend(.hidden)") }
        return lines.joined(separator: "\n")
    }

    private func copy(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
        copied = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            copied = false
        }
    }
}
