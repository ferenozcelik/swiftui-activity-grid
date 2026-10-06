import SwiftUI
import SwiftUIActivityGrid

/// Every built-in style, at its real size.
struct StylesPage: View {
    private let values = SampleData.values()

    var body: some View {
        ShowcasePage("Styles", caption: "Built-in styles at their real size. Set one with .activityGridStyle(_:).") {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], alignment: .leading, spacing: 22) {
                Specimen("Automatic", code: ".automatic") {
                    grid(.automatic)
                }
                Specimen("Squares", code: ".squares") {
                    grid(.squares)
                }
                Specimen("Rounded", code: ".rounded") {
                    grid(.rounded)
                }
                Specimen("Circles", code: ".circles") {
                    grid(.circles)
                }
                Specimen("Minimal", code: ".minimal") {
                    grid(.minimal)
                }
                Specimen("Your mix", code: "DefaultActivityGridStyle") {
                    grid(DefaultActivityGridStyle(shape: .circle, emptyCell: .outlined(lineWidth: 1), metrics: .large))
                }
            }
        }
        .activityGridMonthLabels(.hidden)
        .activityGridWeekdayLabels(.hidden)
        .activityGridLegend(.hidden)
    }

    private func grid(_ style: DefaultActivityGridStyle) -> some View {
        ActivityGrid(values, range: .lastWeeks(16))
            .activityGridStyle(style)
    }
}
