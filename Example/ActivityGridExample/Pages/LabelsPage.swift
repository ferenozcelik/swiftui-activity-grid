import SwiftUI
import SwiftUIActivityGrid

/// Month labels, weekday labels and the legend: shown, hidden or your own.
struct LabelsPage: View {
    private let values = SampleData.values()

    var body: some View {
        ShowcasePage("Labels and legend", caption: "Show, hide or replace the labels and the legend.") {
            Specimen("Default", code: "no modifiers") {
                ActivityGrid(values, range: .lastMonths(8))
            }
            Specimen("Every weekday, Monday first", code: ".activityGridWeekdayLabels(.all)\n.activityGridFirstWeekday(.monday)") {
                ActivityGrid(values, range: .lastMonths(8))
                    .activityGridWeekdayLabels(.all)
                    .activityGridFirstWeekday(.monday)
            }
            Specimen("Your own text", code: ".activityGridMonthLabels(.custom { … })\n.activityGridWeekdayLabels(.custom { … })\n.activityGridLegend(.bottomTrailing(less:more:))") {
                ActivityGrid(values, range: .lastMonths(8))
                    .activityGridMonthLabels(.custom { month in
                        Text(month.date, format: .dateTime.month(.narrow))
                    })
                    .activityGridWeekdayLabels(.custom { weekday in
                        switch weekday {
                        case .monday: Text("M")
                        case .wednesday: Text("W")
                        case .friday: Text("F")
                        default: nil
                        }
                    })
                    .activityGridLegend(.bottomTrailing(less: Text("Rest"), more: Text("Busy")))
            }
            Specimen("Hidden labels, your own legend", code: ".activityGridMonthLabels(.hidden)\n.activityGridWeekdayLabels(.hidden)\n.activityGridLegend(.custom { palette in … })") {
                ActivityGrid(values, range: .lastMonths(8))
                    .activityGridMonthLabels(.hidden)
                    .activityGridWeekdayLabels(.hidden)
                    .activityGridLegend(.custom { palette in
                        HStack(spacing: 4) {
                            Text("0 h")
                            ForEach(0...palette.levelCount, id: \.self) { level in
                                Circle()
                                    .fill(palette.color(forLevel: level))
                                    .frame(width: 9, height: 9)
                            }
                            Text("2+ h")
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    })
            }
        }
        .activityGridDisplayMode(.fit)
        .activityGridPalette(.purple)
    }
}
