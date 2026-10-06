import SwiftUI
import SwiftUIActivityGrid

/// Exporting a grid as an image for social media.
struct SharePage: View {
    private enum Size: String, CaseIterable, Identifiable {
        case story = "Story", square = "Square", landscape = "Landscape"
        var id: String { rawValue }
        var format: ActivityGridShareFormat {
            switch self {
            case .story: .story
            case .square: .square
            case .landscape: .landscape
            }
        }
    }

    private enum Weeks: String, CaseIterable, Identifiable {
        case year = "Year", sixMonths = "6 months", threeMonths = "3 months"
        var id: String { rawValue }
        var range: ActivityGridRange {
            switch self {
            case .year: .lastYear
            case .sixMonths: .lastMonths(6)
            case .threeMonths: .lastMonths(3)
            }
        }
    }

    private let values = SampleData.values()

    @Environment(\.colorScheme) private var colorScheme
    @State private var size: Size = .story
    @State private var weeks: Weeks = .year
    @State private var top = false
    @State private var preview: Image?

    private var card: some View {
        ActivityGridShareCard(
            format: size.format,
            title: Text("My year of reading"),
            subtitle: Text("Pages per day"),
            footer: Text("my-app.com"),
            gridAlignment: top ? .top : .center
        ) {
            ActivityGrid(values, range: weeks.range)
                .activityGridPalette(.green)
                .activityGridStyle(.rounded)
        }
    }

    var body: some View {
        ShowcasePage("Share", caption: "Export a card as a PNG image. Nothing is shown in your app until you add the button.") {
            Picker("Size", selection: $size) {
                ForEach(Size.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            Picker("Range", selection: $weeks) {
                ForEach(Weeks.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            Toggle("Grid at the top", isOn: $top)

            Specimen(code: "ActivityGridShareButton(\"Share\", fileName: …) { card }") {
                preview?
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 380)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.quaternary))
                    .frame(maxWidth: .infinity)
            }

            ActivityGridShareButton("Share", fileName: "My year of reading", format: size.format) {
                card
            }
            .buttonStyle(.borderedProminent)
        }
        .task(id: "\(size.rawValue)\(weeks.rawValue)\(top)\(colorScheme == .dark)") { render() }
    }

    private func render() {
        preview = ActivityGridExporter.image(card, format: size.format, colorScheme: colorScheme)
    }
}
