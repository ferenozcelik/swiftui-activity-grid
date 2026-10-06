import SwiftUI
import SwiftUIActivityGrid

/// The same data over different date ranges.
struct RangesPage: View {
    private let values = SampleData.values()

    private var lastMonth: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    }

    private var lastQuarter: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let start = calendar.date(byAdding: .day, value: -70, to: today) ?? today
        let end = calendar.date(byAdding: .day, value: -14, to: today) ?? today
        return start...end
    }

    var body: some View {
        ShowcasePage("Ranges", caption: "Pass a range: ActivityGrid(values, range: …)") {
            Specimen("Last year", code: ".lastYear  // the default, scrolls") {
                ActivityGrid(values, range: .lastYear)
                    .activityGridDisplayMode(.scrollable)
            }
            Specimen("Last 6 months", code: ".lastMonths(6)") {
                ActivityGrid(values, range: .lastMonths(6))
            }
            HStack(alignment: .top, spacing: 20) {
                Specimen("One month", code: ".month(containing: date)") {
                    ActivityGrid(values, range: .month(containing: lastMonth))
                        .activityGridWeekdayLabels(.all)
                        .activityGridStyle(.rounded)
                        .frame(height: 135, alignment: .topLeading)
                }
                Specimen("Custom", code: ".custom(start...end)") {
                    ActivityGrid(values, range: .custom(lastQuarter))
                        .activityGridStyle(.rounded)
                        .frame(height: 135, alignment: .topLeading)
                }
            }
            HStack(alignment: .top, spacing: 20) {
                Specimen("Last 12 weeks", code: ".lastWeeks(12)") {
                    ActivityGrid(values, range: .lastWeeks(12))
                        .activityGridStyle(.circles)
                        .activityGridWeekdayLabels(.hidden)
                        .frame(height: 105, alignment: .topLeading)
                }
                Specimen("Last 30 days", code: ".lastDays(30)") {
                    ActivityGrid(values, range: .lastDays(30))
                        .activityGridStyle(.circles)
                        .activityGridWeekdayLabels(.hidden)
                        .frame(height: 105, alignment: .topLeading)
                }
            }
        }
        .activityGridDisplayMode(.fit)
        .activityGridLegend(.hidden)
    }
}
