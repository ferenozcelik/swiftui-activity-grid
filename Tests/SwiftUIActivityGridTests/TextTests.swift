import XCTest
@testable import SwiftUIActivityGrid

final class TextTests: XCTestCase {
    private func text(_ identifier: String) -> ActivityGridText {
        var calendar = makeCalendar()
        calendar.locale = Locale(identifier: identifier)
        return ActivityGridText(calendar: calendar)
    }

    /// Xcode compiles the String Catalog into `.lproj` folders; plain `swift build` only copies it.
    private func skipUnlessCatalogIsCompiled() throws {
        try XCTSkipIf(
            Bundle.module.path(forResource: "en", ofType: "lproj") == nil,
            "The String Catalog is only compiled by Xcode builds (xcodebuild test)."
        )
    }

    func testEnglishTexts() throws {
        try skipUnlessCatalogIsCompiled()
        let english = text("en_US")
        XCTAssertEqual(english.less, "Less")
        XCTAssertEqual(english.value(1, formatter: nil), "1 activity")
        XCTAssertEqual(english.value(5, formatter: nil), "5 activities")
    }

    func testOtherLocalesUseEnglishTexts() throws {
        try skipUnlessCatalogIsCompiled()
        XCTAssertEqual(text("ja_JP").less, "Less")
    }

    func testValueFormatterAndEmptyDays() {
        let english = text("en_US")
        XCTAssertEqual(english.value(32, formatter: { "\(Int($0)) min" }), "32 min")
        XCTAssertEqual(english.value(nil, formatter: { _ in "unused" }), english.noActivity)
        XCTAssertEqual(english.value(0, formatter: nil), english.noActivity)
    }
}
