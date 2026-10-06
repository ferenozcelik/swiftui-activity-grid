import SwiftUI
import CoreTransferable
import UniformTypeIdentifiers

/// The file type of a shared image.
public enum ActivityGridExportFileType: Sendable {
    case png
    case pdf
}

/// A button that opens the share sheet with an image of a card.
///
/// Nothing is shown unless you add this button. The image is made only when the person picks a
/// share target, and it never leaves the device unless they choose to send it.
///
/// ```swift
/// ActivityGridShareButton("Share", fileName: "My year") {
///     ActivityGridShareCard(format: .story, title: Text("My year")) {
///         ActivityGrid(values)
///     }
/// }
/// ```
///
/// The palette, style, labels, calendar and locale set on the view around the button are used for
/// the image too, and so is light or dark mode unless you pass `colorScheme`.
public struct ActivityGridShareButton<Label: View, Card: View>: View {
    private let fileName: String
    private let format: ActivityGridShareFormat
    private let fileType: ActivityGridExportFileType
    private let colorScheme: ColorScheme?
    private let card: @MainActor () -> Card
    private let label: Label

    /// Creates a button with your own label.
    ///
    /// - Parameters:
    ///   - fileName: The name shown in the share sheet and given to the file.
    ///   - format: Size of the image. It must match the card's format.
    ///   - fileType: PNG (default) or PDF.
    ///   - colorScheme: Force light or dark. The default follows the current appearance.
    ///   - card: The card to export.
    ///   - label: The button's label.
    public init(
        fileName: String,
        format: ActivityGridShareFormat = .square,
        fileType: ActivityGridExportFileType = .png,
        colorScheme: ColorScheme? = nil,
        @ViewBuilder card: @escaping @MainActor () -> Card,
        @ViewBuilder label: () -> Label
    ) {
        self.fileName = fileName
        self.format = format
        self.fileType = fileType
        self.colorScheme = colorScheme
        self.card = card
        self.label = label()
    }

    public var body: some View {
        EnvironmentSnapshotReader { snapshot, currentScheme in
            let scheme = colorScheme ?? currentScheme
            let (card, format) = (self.card, self.format)
            let render = Renderer(
                png: { ActivityGridExporter.pngData(snapshot.apply(to: card()), format: format, colorScheme: scheme) },
                pdf: { ActivityGridExporter.pdfData(snapshot.apply(to: card()), format: format, colorScheme: scheme) }
            )
            switch fileType {
            case .png:
                ShareLink(item: ActivityGridPNGFile(name: fileName, render: render), preview: SharePreview(fileName)) { label }
            case .pdf:
                ShareLink(item: ActivityGridPDFFile(name: fileName, render: render), preview: SharePreview(fileName)) { label }
            }
        }
    }
}

extension ActivityGridShareButton where Label == SwiftUI.Label<Text, Image> {
    /// Creates a button with a title and the system share icon.
    public init(
        _ title: LocalizedStringKey,
        fileName: String,
        format: ActivityGridShareFormat = .square,
        fileType: ActivityGridExportFileType = .png,
        colorScheme: ColorScheme? = nil,
        @ViewBuilder card: @escaping @MainActor () -> Card
    ) {
        self.init(fileName: fileName, format: format, fileType: fileType, colorScheme: colorScheme, card: card) {
            SwiftUI.Label(title, systemImage: "square.and.arrow.up")
        }
    }
}

// MARK: - Files

private func temporaryFile(named name: String, extension ext: String, data: Data) throws -> SentTransferredFile {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let safeName = name.replacingOccurrences(of: "/", with: "-")
    let url = directory.appendingPathComponent(safeName).appendingPathExtension(ext)
    try data.write(to: url)
    return SentTransferredFile(url)
}

/// Renders on the main actor when the share sheet asks for the file.
struct Renderer: @unchecked Sendable {
    let png: @MainActor () -> Data?
    let pdf: @MainActor () -> Data?
}

private struct ExportFailed: Error {}

struct ActivityGridPNGFile: Transferable {
    let name: String
    let render: Renderer

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .png) { item in
            let data = await MainActor.run { item.render.png() }
            guard let data else { throw ExportFailed() }
            return try temporaryFile(named: item.name, extension: "png", data: data)
        }
    }
}

struct ActivityGridPDFFile: Transferable {
    let name: String
    let render: Renderer

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .pdf) { item in
            let data = await MainActor.run { item.render.pdf() }
            guard let data else { throw ExportFailed() }
            return try temporaryFile(named: item.name, extension: "pdf", data: data)
        }
    }
}

// MARK: - Environment

/// The grid settings of the view around the button, replayed on the exported card.
struct EnvironmentSnapshot: @unchecked Sendable {
    var style: AnyActivityGridStyle
    var palette: ActivityPalette
    var mapping: ActivityLevelMapping
    var calendar: Calendar?
    var firstWeekday: Locale.Weekday?
    var monthLabels: MonthLabelVisibility
    var weekdayLabels: WeekdayLabelVisibility
    var legend: ActivityGridLegend
    var now: Date?
    var valueFormatter: (@MainActor @Sendable (Double) -> String)?
    var summary: (@MainActor @Sendable (ActivityGridSummary) -> Text)?
    var locale: Locale
    var dynamicTypeSize: DynamicTypeSize

    @MainActor func apply<V: View>(to view: V) -> some View {
        view
            .environment(\.activityGridStyle, style)
            .environment(\.activityGridPalette, palette)
            .environment(\.activityGridLevelMapping, mapping)
            .environment(\.activityGridCalendar, calendar)
            .environment(\.activityGridFirstWeekday, firstWeekday)
            .environment(\.activityGridMonthLabels, monthLabels)
            .environment(\.activityGridWeekdayLabels, weekdayLabels)
            .environment(\.activityGridLegend, legend)
            .environment(\.activityGridNow, now)
            .environment(\.activityGridValueFormatter, valueFormatter)
            .environment(\.activityGridSummary, summary)
            .environment(\.locale, locale)
            .environment(\.dynamicTypeSize, dynamicTypeSize)
    }
}

private struct EnvironmentSnapshotReader<Content: View>: View {
    @ViewBuilder let content: (EnvironmentSnapshot, ColorScheme) -> Content

    @Environment(\.activityGridStyle) private var style
    @Environment(\.activityGridPalette) private var palette
    @Environment(\.activityGridLevelMapping) private var mapping
    @Environment(\.activityGridCalendar) private var calendar
    @Environment(\.activityGridFirstWeekday) private var firstWeekday
    @Environment(\.activityGridMonthLabels) private var monthLabels
    @Environment(\.activityGridWeekdayLabels) private var weekdayLabels
    @Environment(\.activityGridLegend) private var legend
    @Environment(\.activityGridNow) private var now
    @Environment(\.activityGridValueFormatter) private var valueFormatter
    @Environment(\.activityGridSummary) private var summary
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        content(
            EnvironmentSnapshot(
                style: style, palette: palette, mapping: mapping, calendar: calendar, firstWeekday: firstWeekday,
                monthLabels: monthLabels, weekdayLabels: weekdayLabels, legend: legend, now: now,
                valueFormatter: valueFormatter, summary: summary, locale: locale, dynamicTypeSize: dynamicTypeSize
            ),
            colorScheme
        )
    }
}
