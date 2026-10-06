import SwiftUI

/// A card that puts a grid, with an optional title, subtitle and footer, on a background.
/// Export it with ``ActivityGridExporter`` or ``ActivityGridShareButton``.
///
/// ```swift
/// ActivityGridShareCard(
///     format: .story,
///     title: Text("My year of running"),
///     subtitle: Text("2025"),
///     footer: Text("my-app.com")
/// ) {
///     ActivityGrid(runs, range: .lastYear)
/// }
/// ```
///
/// The grid inside is always shown in the `.fit` display mode so that the whole range is visible.
/// The card adds nothing of its own: no logo and no watermark.
public struct ActivityGridShareCard<Grid: View>: View {
    private let format: ActivityGridShareFormat
    private let title: Text?
    private let subtitle: Text?
    private let footer: Text?
    private let background: AnyShapeStyle?
    private let grid: Grid

    @Environment(\.colorScheme) private var colorScheme

    /// - Parameters:
    ///   - format: The size of the card.
    ///   - title: Large text above the grid.
    ///   - subtitle: Smaller text under the title.
    ///   - footer: Small text at the bottom, like your app's name or web address.
    ///   - background: Color or gradient behind the card. The default is white in light mode and
    ///     near black in dark mode. Pass `Color.clear` for a transparent PNG.
    ///   - grid: The grid to show.
    public init<Background: ShapeStyle>(
        format: ActivityGridShareFormat = .square,
        title: Text? = nil,
        subtitle: Text? = nil,
        footer: Text? = nil,
        background: Background,
        @ViewBuilder grid: () -> Grid
    ) {
        self.format = format
        self.title = title
        self.subtitle = subtitle
        self.footer = footer
        self.background = AnyShapeStyle(background)
        self.grid = grid()
    }

    /// Creates a card with the default background.
    public init(
        format: ActivityGridShareFormat = .square,
        title: Text? = nil,
        subtitle: Text? = nil,
        footer: Text? = nil,
        @ViewBuilder grid: () -> Grid
    ) {
        self.format = format
        self.title = title
        self.subtitle = subtitle
        self.footer = footer
        self.background = nil
        self.grid = grid()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 2) {
                    title?.font(.title2.weight(.bold))
                    subtitle?.font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.bottom, 16)
            }
            if format.height != nil { Spacer(minLength: 0) }
            grid
                .activityGridDisplayMode(.fit)
            if format.height != nil { Spacer(minLength: 0) }
            if let footer {
                footer
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 16)
            }
        }
        .padding(24)
        .frame(width: format.size.width, height: format.height, alignment: .topLeading)
        .background(fill)
    }

    private var fill: AnyShapeStyle {
        if let background { return background }
        return AnyShapeStyle(colorScheme == .dark ? Color(red: 0.05, green: 0.07, blue: 0.09) : Color.white)
    }
}
