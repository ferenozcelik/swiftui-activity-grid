import SwiftUI

/// The shape of a day cell.
public enum CellShape: Sendable {
    case square
    case roundedRectangle(cornerRadius: CGFloat)
    case circle
    /// Any shape, for example `AnyShape(Capsule())`.
    case custom(AnyShape)

    var shape: AnyShape {
        switch self {
        case .square: AnyShape(Rectangle())
        case .roundedRectangle(let radius): AnyShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        case .circle: AnyShape(Circle())
        case .custom(let shape): shape
        }
    }
}

/// How days without activity are drawn.
public enum EmptyCellStyle: Hashable, Sendable {
    /// Filled with the palette's empty color.
    case filled
    /// An outline in the palette's empty color.
    case outlined(lineWidth: CGFloat)
    /// Not drawn at all.
    case hidden
}

/// How the selected day is marked.
public enum SelectionIndicator: Hashable, Sendable {
    /// A ring in the primary color around the cell.
    case ring
    /// No mark. Useful when the tooltip is enough.
    case none
}

/// The built-in style: plain cells filled with the palette color.
///
/// Use one of the presets, or create your own variant:
///
/// ```swift
/// .activityGridStyle(.circles)
/// .activityGridStyle(DefaultActivityGridStyle(shape: .roundedRectangle(cornerRadius: 4), metrics: .large))
/// ```
public struct DefaultActivityGridStyle: ActivityGridStyle {
    public var shape: CellShape
    public var emptyCell: EmptyCellStyle
    public var metrics: ActivityGridMetrics
    public var selectionIndicator: SelectionIndicator

    public init(
        shape: CellShape = .roundedRectangle(cornerRadius: 2),
        emptyCell: EmptyCellStyle = .filled,
        metrics: ActivityGridMetrics = .standard,
        selectionIndicator: SelectionIndicator = .ring
    ) {
        self.shape = shape
        self.emptyCell = emptyCell
        self.metrics = metrics
        self.selectionIndicator = selectionIndicator
    }

    public func makeCell(configuration: Configuration) -> some View {
        let shape = shape.shape
        ZStack {
            if configuration.level > 0 {
                shape.fill(configuration.color)
            } else {
                switch emptyCell {
                case .filled:
                    shape.fill(configuration.color)
                case .outlined(let lineWidth):
                    shape.stroke(configuration.color, lineWidth: lineWidth)
                        .padding(lineWidth / 2)
                case .hidden:
                    Color.clear
                }
            }
            if configuration.isSelected, selectionIndicator == .ring {
                shape.stroke(Color.primary, lineWidth: 1.5)
            }
        }
    }

    public func metrics(in context: ActivityGridStyleContext) -> ActivityGridMetrics {
        metrics
    }
}

extension ActivityGridStyle where Self == DefaultActivityGridStyle {
    /// The default style: slightly rounded squares.
    public static var automatic: DefaultActivityGridStyle { DefaultActivityGridStyle() }

    /// Small rounded squares with tight gaps.
    public static var squares: DefaultActivityGridStyle {
        DefaultActivityGridStyle(shape: .roundedRectangle(cornerRadius: 2), metrics: ActivityGridMetrics(cellSize: 11, spacing: 3))
    }

    /// Larger, softer squares.
    public static var rounded: DefaultActivityGridStyle {
        DefaultActivityGridStyle(shape: .roundedRectangle(cornerRadius: 4), metrics: .large)
    }

    /// Round dots.
    public static var circles: DefaultActivityGridStyle {
        DefaultActivityGridStyle(shape: .circle)
    }

    /// Sharp squares, with empty days drawn as thin outlines.
    public static var minimal: DefaultActivityGridStyle {
        DefaultActivityGridStyle(shape: .square, emptyCell: .outlined(lineWidth: 1), metrics: ActivityGridMetrics(cellSize: 12, spacing: 2))
    }
}
