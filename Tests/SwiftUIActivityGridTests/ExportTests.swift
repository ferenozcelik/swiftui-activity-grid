import ImageIO
import SwiftUI
import XCTest
@testable import SwiftUIActivityGrid

@MainActor
final class ExportTests: XCTestCase {
    private func card(_ format: ActivityGridShareFormat) -> some View {
        ActivityGridShareCard(format: format, title: Text("Title")) {
            ActivityGrid([Date(): 3], range: .lastWeeks(20))
        }
    }

    func testPixelSizes() {
        XCTAssertEqual(ActivityGridShareFormat.story.pixelSize, CGSize(width: 1080, height: 1920))
        XCTAssertEqual(ActivityGridShareFormat.square.pixelSize, CGSize(width: 1080, height: 1080))
        XCTAssertEqual(ActivityGridShareFormat.landscape.pixelSize, CGSize(width: 1600, height: 900))
        XCTAssertNil(ActivityGridShareFormat.fitContent().pixelSize)
    }

    func testPNGHasTheFormatsPixelSize() throws {
        let data = try XCTUnwrap(ActivityGridExporter.pngData(card(.square), format: .square))
        let source = try XCTUnwrap(CGImageSourceCreateWithData(data as CFData, nil))
        let image = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil))
        XCTAssertEqual(image.width, 1080)
        XCTAssertEqual(image.height, 1080)
    }
}
