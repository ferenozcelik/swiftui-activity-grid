import XCTest
@testable import SwiftUIActivityGrid

final class LocalizationTests: XCTestCase {
    private func text(_ identifier: String) -> ActivityGridText {
        var calendar = makeCalendar()
        calendar.locale = Locale(identifier: identifier)
        return ActivityGridText(calendar: calendar)
    }

    /// Xcode compiles the String Catalog into `.lproj` folders; plain `swift build` only copies it.
    private func skipUnlessCatalogIsCompiled() throws {
        try XCTSkipIf(
            Bundle.module.path(forResource: "tr", ofType: "lproj") == nil,
            "The String Catalog is only compiled by Xcode builds (xcodebuild test)."
        )
    }

    func testLanguageFollowsTheGridLocaleNotTheDevice() throws {
        try skipUnlessCatalogIsCompiled()
        let turkish = text("tr_TR")
        XCTAssertEqual(turkish.less, "Az")
        XCTAssertEqual(turkish.more, "Çok")
        XCTAssertEqual(turkish.value(5, formatter: nil), "5 etkinlik")

        let english = text("en_US")
        XCTAssertEqual(english.value(1, formatter: nil), "1 activity")
        XCTAssertEqual(english.value(5, formatter: nil), "5 activities")
        XCTAssertEqual(english.level(3, of: 4), "Level 3 of 4")
    }

    func testUnsupportedLanguageFallsBackToEnglish() throws {
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
