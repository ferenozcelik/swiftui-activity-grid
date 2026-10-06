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

    private let values = SampleData.values()

    @State private var size: Size = .story
    @State private var dark = false
    @State private var pdf = false
    @State private var preview: Image?

    private var card: some View {
        ActivityGridShareCard(
            format: size.format,
            title: Text("My year of reading"),
            subtitle: Text("Pages per day"),
            footer: Text("my-app.com")
        ) {
            ActivityGrid(values, range: .lastYear)
                .activityGridPalette(.green)
                .activityGridStyle(.rounded)
        }
    }

    var body: some View {
        ShowcasePage("Share", caption: "Export a card as PNG or PDF. Nothing is shown in your app until you add the button.") {
            Picker("Size", selection: $size) {
                ForEach(Size.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            Toggle("Dark", isOn: $dark)
            Toggle("PDF instead of PNG", isOn: $pdf)

            Specimen(code: "ActivityGridShareButton(\"Share\", fileName: …) { card }") {
                preview?
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 380)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(.quaternary))
                    .frame(maxWidth: .infinity)
            }

            ActivityGridShareButton("Share", fileName: "My year of reading", format: size.format, fileType: pdf ? .pdf : .png) {
                card
            }
            .buttonStyle(.borderedProminent)
        }
        .environment(\.colorScheme, dark ? .dark : .light)
        .task(id: "\(size.rawValue)\(dark)") { render() }
    }

    private func render() {
        preview = ActivityGridExporter.image(
            card.activityGridNow(.now),
            format: size.format,
            colorScheme: dark ? .dark : .light
        )
    }
}
