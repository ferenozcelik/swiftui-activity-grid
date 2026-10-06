import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// The sRGB components of a `Color`, resolved for a color scheme.
struct ColorComponents: Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double

    init(red: Double, green: Double, blue: Double, opacity: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    init(_ color: Color, in scheme: ColorScheme) {
        if #available(iOS 17, macOS 14, watchOS 10, visionOS 1, *) {
            var environment = EnvironmentValues()
            environment.colorScheme = scheme
            let resolved = color.resolve(in: environment)
            self.init(red: Double(resolved.red), green: Double(resolved.green), blue: Double(resolved.blue), opacity: Double(resolved.opacity))
        } else {
            self = Self.platformComponents(of: color, in: scheme)
        }
    }

    func interpolated(to other: ColorComponents, fraction: Double) -> ColorComponents {
        func mix(_ a: Double, _ b: Double) -> Double { a + (b - a) * fraction }
        return ColorComponents(
            red: mix(red, other.red),
            green: mix(green, other.green),
            blue: mix(blue, other.blue),
            opacity: mix(opacity, other.opacity)
        )
    }

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    /// Before iOS 17 / macOS 14, a `Color` can only be resolved through UIKit or AppKit.
    private static func platformComponents(of color: Color, in scheme: ColorScheme) -> ColorComponents {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1
        #if canImport(UIKit) && !os(watchOS)
        let traits = UITraitCollection(userInterfaceStyle: scheme == .dark ? .dark : .light)
        UIColor(color).resolvedColor(with: traits).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif os(watchOS)
        // watchOS has no light mode, so there is nothing to resolve.
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #elseif canImport(AppKit)
        let appearance = NSAppearance(named: scheme == .dark ? .darkAqua : .aqua)
        appearance?.performAsCurrentDrawingAppearance {
            if let rgb = NSColor(color).usingColorSpace(.sRGB) {
                rgb.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            }
        }
        #endif
        return ColorComponents(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
}
