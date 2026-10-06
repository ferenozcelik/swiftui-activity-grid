import SwiftUI

/// The colors of an ``ActivityGrid``: one for empty days and one per level.
///
/// The number of `levels` colors decides how many levels the grid has; the
/// level mapping always uses that count. A palette can have separate colors
/// for light and dark mode.
///
/// ```swift
/// ActivityGrid(values)
///     .activityGridPalette(.blue)
///
/// ActivityGrid(values)
///     .activityGridPalette(.gradient(from: .yellow, to: .red, levels: 5, empty: .gray.opacity(0.15)))
/// ```
public struct ActivityPalette: Hashable, Sendable {
    /// The color of days without activity.
    public var empty: Color
    /// The colors of levels `1` through `levels.count`, from least to most activity.
    public var levels: [Color]
    private var dark: Colors?

    private struct Colors: Hashable, Sendable {
        var empty: Color
        var levels: [Color]
    }

    /// Creates a palette that looks the same in light and dark mode.
    ///
    /// - Parameters:
    ///   - empty: The color of days without activity.
    ///   - levels: The colors of the levels, from least to most activity. Needs at least one color.
    public init(empty: Color, levels: [Color]) {
        self.empty = empty
        self.levels = levels.isEmpty ? [.accentColor] : levels
    }

    /// Creates a palette that switches colors with the color scheme.
    ///
    /// Both palettes should have the same number of levels. If they don't, the light one's count wins
    /// and the dark colors are repeated or cut to match.
    public init(light: ActivityPalette, dark: ActivityPalette) {
        self.init(empty: light.empty, levels: light.levels)
        let darkLevels = (0..<light.levels.count).map { dark.levels[min($0, dark.levels.count - 1)] }
        self.dark = Colors(empty: dark.empty, levels: darkLevels)
    }

    /// The number of non-empty levels.
    public var levelCount: Int { levels.count }

    /// The color of `level`, where `0` is ``empty``.
    public func color(forLevel level: Int) -> Color {
        guard level > 0 else { return empty }
        return levels[min(level, levels.count) - 1]
    }

    /// The colors to use in `colorScheme`, as a palette without a dark variant.
    public func resolved(for colorScheme: ColorScheme) -> ActivityPalette {
        guard colorScheme == .dark, let dark else {
            return ActivityPalette(empty: empty, levels: levels)
        }
        return ActivityPalette(empty: dark.empty, levels: dark.levels)
    }
}

// MARK: - Built-in palettes

extension ActivityPalette {
    /// GitHub-style greens. The default.
    public static let green = ActivityPalette(
        light: ActivityPalette(empty: Color(hex: 0xEBEDF0), levels: [0x9BE9A8, 0x40C463, 0x30A14E, 0x216E39].map(Color.init(hex:))),
        dark: ActivityPalette(empty: Color(hex: 0x161B22), levels: [0x0E4429, 0x006D32, 0x26A641, 0x39D353].map(Color.init(hex:)))
    )

    /// Blues.
    public static let blue = ActivityPalette(
        light: ActivityPalette(empty: Color(hex: 0xEBEDF0), levels: [0xBBDEFB, 0x64B5F6, 0x1E88E5, 0x0D47A1].map(Color.init(hex:))),
        dark: ActivityPalette(empty: Color(hex: 0x161B22), levels: [0x0D2A4D, 0x1458A6, 0x2F81F7, 0x79C0FF].map(Color.init(hex:)))
    )

    /// Oranges.
    public static let orange = ActivityPalette(
        light: ActivityPalette(empty: Color(hex: 0xEBEDF0), levels: [0xFFE0B2, 0xFFB74D, 0xF57C00, 0xBF360C].map(Color.init(hex:))),
        dark: ActivityPalette(empty: Color(hex: 0x161B22), levels: [0x4A2A0A, 0x8A4A0F, 0xD9771C, 0xFFB15C].map(Color.init(hex:)))
    )

    /// Purples.
    public static let purple = ActivityPalette(
        light: ActivityPalette(empty: Color(hex: 0xEBEDF0), levels: [0xE1BEE7, 0xBA68C8, 0x8E24AA, 0x4A148C].map(Color.init(hex:))),
        dark: ActivityPalette(empty: Color(hex: 0x161B22), levels: [0x3B1A4F, 0x6A2C91, 0xA35BD6, 0xD2A8FF].map(Color.init(hex:)))
    )

    /// Viridis, a palette that stays readable with the common kinds of color blindness.
    ///
    /// More activity is darker in light mode and brighter in dark mode.
    public static let viridis = ActivityPalette(
        light: ActivityPalette(empty: Color(hex: 0xEBEDF0), levels: [0xFDE725, 0x5EC962, 0x21918C, 0x3B528B].map(Color.init(hex:))),
        dark: ActivityPalette(empty: Color(hex: 0x161B22), levels: [0x3B528B, 0x21918C, 0x5EC962, 0xFDE725].map(Color.init(hex:)))
    )

    /// Shades of gray.
    public static let monochrome = ActivityPalette(
        light: ActivityPalette(empty: Color(hex: 0xEBEDF0), levels: [0xBDBDBD, 0x8A8A8A, 0x575757, 0x262626].map(Color.init(hex:))),
        dark: ActivityPalette(empty: Color(hex: 0x161B22), levels: [0x3A3A3A, 0x6B6B6B, 0xA3A3A3, 0xE6E6E6].map(Color.init(hex:)))
    )

    /// One color at increasing opacity, for example your app's accent color.
    ///
    /// - Parameters:
    ///   - base: The color of the top level.
    ///   - levels: The number of non-empty levels.
    public static func opacity(_ base: Color, levels: Int = 4) -> ActivityPalette {
        let count = max(levels, 1)
        let colors = (1...count).map { level in
            base.opacity(count == 1 ? 1 : 0.25 + 0.75 * Double(level - 1) / Double(count - 1))
        }
        return ActivityPalette(empty: base.opacity(0.1), levels: colors)
    }

    /// Colors blended evenly from one color to another.
    ///
    /// The colors are mixed in sRGB. Colors that adapt to the color scheme (like `.accentColor`
    /// or asset catalog colors) are mixed separately for light and dark mode.
    ///
    /// - Parameters:
    ///   - from: The color of level 1.
    ///   - to: The color of the top level.
    ///   - levels: The number of non-empty levels.
    ///   - empty: The color of days without activity.
    public static func gradient(from: Color, to: Color, levels: Int = 4, empty: Color) -> ActivityPalette {
        let count = max(levels, 1)
        func colors(in scheme: ColorScheme) -> [Color] {
            let start = ColorComponents(from, in: scheme)
            let end = ColorComponents(to, in: scheme)
            return (1...count).map { level in
                let fraction = count == 1 ? 1 : Double(level - 1) / Double(count - 1)
                return start.interpolated(to: end, fraction: fraction).color
            }
        }
        return ActivityPalette(
            light: ActivityPalette(empty: empty, levels: colors(in: .light)),
            dark: ActivityPalette(empty: empty, levels: colors(in: .dark))
        )
    }
}

extension Color {
    /// A color from a hex value like `0x40C463`, in sRGB.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
