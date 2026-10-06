import SwiftUI
import ImageIO
import UniformTypeIdentifiers

/// Turns a view into PNG or PDF data. Everything happens on the device. Nothing is sent anywhere.
///
/// Rendering starts from a fresh environment, so values you set outside the view, like the palette,
/// style or locale, are not carried over. Set them on the view you pass in, or use
/// ``ActivityGridShareButton``, which carries them over for you.
@MainActor
public enum ActivityGridExporter {
    /// Renders `content` to PNG data.
    ///
    /// - Parameters:
    ///   - content: The view, usually an ``ActivityGridShareCard``.
    ///   - format: Size and scale of the image.
    ///   - colorScheme: Light or dark. The default is light.
    public static func pngData<Content: View>(
        _ content: Content,
        format: ActivityGridShareFormat = .square,
        colorScheme: ColorScheme = .light
    ) -> Data? {
        let renderer = makeRenderer(content, format: format, colorScheme: colorScheme)
        renderer.scale = format.scale
        guard let image = renderer.cgImage else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, image, nil)
        return CGImageDestinationFinalize(destination) ? data as Data : nil
    }

    /// Renders `content` to a one-page PDF. The grid is drawn as vectors.
    public static func pdfData<Content: View>(
        _ content: Content,
        format: ActivityGridShareFormat = .square,
        colorScheme: ColorScheme = .light
    ) -> Data? {
        let renderer = makeRenderer(content, format: format, colorScheme: colorScheme)
        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data) else { return nil }
        var rendered = false
        var mediaBox = CGRect.zero
        renderer.render { size, draw in
            mediaBox = CGRect(origin: .zero, size: size)
            guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else { return }
            context.beginPDFPage(nil)
            draw(context)
            context.endPDFPage()
            context.closePDF()
            rendered = true
        }
        return rendered ? data as Data : nil
    }

    /// Renders `content` to a SwiftUI `Image`, for showing a preview.
    public static func image<Content: View>(
        _ content: Content,
        format: ActivityGridShareFormat = .square,
        colorScheme: ColorScheme = .light
    ) -> Image? {
        let renderer = makeRenderer(content, format: format, colorScheme: colorScheme)
        renderer.scale = format.scale
        guard let image = renderer.cgImage else { return nil }
        return Image(decorative: image, scale: format.scale)
    }

    private static func makeRenderer<Content: View>(
        _ content: Content,
        format: ActivityGridShareFormat,
        colorScheme: ColorScheme
    ) -> ImageRenderer<some View> {
        let renderer = ImageRenderer(content: content.environment(\.colorScheme, colorScheme))
        renderer.proposedSize = ProposedViewSize(width: format.size.width, height: format.height)
        return renderer
    }
}
