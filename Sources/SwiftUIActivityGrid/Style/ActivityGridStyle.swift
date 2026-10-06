import SwiftUI

/// Draws the day cells of an ``ActivityGrid``.
///
/// Works like `ButtonStyle`: build a cell from its configuration and apply the
/// style with ``SwiftUICore/View/activityGridStyle(_:)``, once on a container
/// or on each grid.
///
/// ```swift
/// struct DotStyle: ActivityGridStyle {
///     func makeCell(configuration: Configuration) -> some View {
///         Circle()
///             .fill(configuration.color)
///             .scaleEffect(configuration.level == 0 ? 0.4 : 1)
///     }
/// }
/// ```
///
/// The grid gives each cell its frame and places it, so a cell should fill the space it's offered.
public protocol ActivityGridStyle: Sendable {
    /// The view of one day.
    associatedtype Cell: View

    typealias Configuration = ActivityGridCellConfiguration

    /// Creates the view of one day.
    @ViewBuilder @MainActor func makeCell(configuration: Configuration) -> Cell

    /// The size of the cells and the gaps between them.
    ///
    /// The default implementation returns ``ActivityGridMetrics/standard``. In
    /// ``ActivityGridDisplayMode/fit`` mode, the cell size scales to fill the space
    /// and only the ratio between cell size and spacing is kept.
    func metrics(in context: ActivityGridStyleContext) -> ActivityGridMetrics
}

extension ActivityGridStyle {
    public func metrics(in context: ActivityGridStyleContext) -> ActivityGridMetrics {
        .standard
    }
}

/// Everything a style needs to draw one day.
public struct ActivityGridCellConfiguration: Sendable {
    /// The day, with its value and level.
    public let day: ActivityDay
    /// The day's level, from `0` (no activity) up to ``levelCount``.
    public var level: Int { day.level }
    /// The number of non-empty levels.
    public var levelCount: Int { day.levelCount }
    /// The palette color of the day's level, already resolved for the color scheme.
    public let color: Color
    /// `true` while the day is selected.
    public let isSelected: Bool
    /// The whole palette, resolved for the color scheme.
    public let palette: ActivityPalette

    /// Creates a configuration, for example to preview a custom style.
    public init(day: ActivityDay, color: Color, isSelected: Bool, palette: ActivityPalette) {
        self.day = day
        self.color = color
        self.isSelected = isSelected
        self.palette = palette
    }
}

/// The size of the cells and the gaps around them.
public struct ActivityGridMetrics: Hashable, Sendable {
    /// The width and height of a day cell.
    public var cellSize: CGFloat
    /// The gap between cells.
    public var spacing: CGFloat
    /// The gap between the cells and the month labels, weekday labels and legend.
    public var labelSpacing: CGFloat

    public init(cellSize: CGFloat, spacing: CGFloat, labelSpacing: CGFloat = 4) {
        self.cellSize = max(cellSize, 1)
        self.spacing = max(spacing, 0)
        self.labelSpacing = max(labelSpacing, 0)
    }

    /// 12-point cells with 3-point gaps.
    public static let standard = ActivityGridMetrics(cellSize: 12, spacing: 3)
    /// 10-point cells with 2-point gaps.
    public static let small = ActivityGridMetrics(cellSize: 10, spacing: 2)
    /// 16-point cells with 4-point gaps.
    public static let large = ActivityGridMetrics(cellSize: 16, spacing: 4, labelSpacing: 6)
}

/// What a style can take into account when it picks its metrics.
public struct ActivityGridStyleContext: Sendable {
    /// How the grid is laid out.
    public let displayMode: ActivityGridDisplayMode
    /// The current Dynamic Type size.
    public let dynamicTypeSize: DynamicTypeSize

    public init(displayMode: ActivityGridDisplayMode, dynamicTypeSize: DynamicTypeSize) {
        self.displayMode = displayMode
        self.dynamicTypeSize = dynamicTypeSize
    }
}

/// A type-erased style, stored in the environment.
struct AnyActivityGridStyle: Sendable {
    private let makeCellView: @MainActor @Sendable (ActivityGridCellConfiguration) -> AnyView
    private let makeMetrics: @Sendable (ActivityGridStyleContext) -> ActivityGridMetrics

    init<S: ActivityGridStyle>(_ style: S) {
        makeCellView = { AnyView(style.makeCell(configuration: $0)) }
        makeMetrics = { style.metrics(in: $0) }
    }

    @MainActor func makeCell(configuration: ActivityGridCellConfiguration) -> AnyView {
        makeCellView(configuration)
    }

    func metrics(in context: ActivityGridStyleContext) -> ActivityGridMetrics {
        makeMetrics(context)
    }
}
