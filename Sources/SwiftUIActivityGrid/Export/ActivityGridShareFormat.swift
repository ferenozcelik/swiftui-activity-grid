import CoreGraphics

/// The size of an exported image.
///
/// Sizes are laid out in points and exported at a scale, so the pixel size is exact:
/// ``story`` is always 1080 × 1920 pixels.
public struct ActivityGridShareFormat: Hashable, Sendable {
    /// The layout size in points. `height` is `nil` when the content decides its own height.
    public let size: CGSize
    public let height: CGFloat?
    /// How many pixels each point becomes.
    public let scale: CGFloat

    private init(width: CGFloat, height: CGFloat?, scale: CGFloat) {
        self.size = CGSize(width: width, height: height ?? 0)
        self.height = height
        self.scale = scale
    }

    /// 1080 × 1920 pixels. For Instagram and TikTok stories.
    public static let story = ActivityGridShareFormat(width: 360, height: 640, scale: 3)

    /// 1080 × 1080 pixels. For Instagram posts.
    public static let square = ActivityGridShareFormat(width: 360, height: 360, scale: 3)

    /// 1600 × 900 pixels. For X and LinkedIn.
    public static let landscape = ActivityGridShareFormat(width: 800, height: 450, scale: 2)

    /// A fixed width, with the height set by the content. Use it for just the grid, without a card.
    public static func fitContent(width: CGFloat = 360, scale: CGFloat = 3) -> ActivityGridShareFormat {
        ActivityGridShareFormat(width: width, height: nil, scale: scale)
    }

    /// Your own size, in points.
    public static func custom(size: CGSize, scale: CGFloat = 3) -> ActivityGridShareFormat {
        ActivityGridShareFormat(width: size.width, height: size.height, scale: scale)
    }

    /// The size of the exported PNG in pixels, or `nil` for ``fitContent(width:scale:)``,
    /// where the height is only known after layout.
    public var pixelSize: CGSize? {
        height.map { CGSize(width: size.width * scale, height: $0 * scale) }
    }
}
