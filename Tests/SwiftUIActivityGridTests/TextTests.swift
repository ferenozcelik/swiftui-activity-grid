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
        XCTAssertEqual(english.level(3, of: 4), "Level 3 of 4")
        let calendar = makeCalendar()
        let summary = ActivityGridSummary(range: date(2025, 3, 3, in: calendar)...date(2025, 3, 9, in: calendar), activeDays: 1)
        XCTAssertTrue(english.summary(summary).hasSuffix(". 1 active day."))
    }

    func testOtherLocalesUseEnglishTexts() throws {
        try skipUnlessCatalogIsCompiled()
        XCTAssertEqual(text("ja_JP").less, "Less")
    }

    func testSummaryCountsActiveDaysInRange() {
        let calendar = makeCalendar()
        let data = ActivityGridData([
            date(2025, 3, 2, in: calendar): 4,
            date(2025, 3, 3, 8, in: calendar): 1,
            date(2025, 3, 4, in: calendar): 0,
            date(2025, 3, 9, 23, in: calendar): 2,
            date(2025, 3, 10, in: calendar): 5,
        ], calendar: calendar)
        let range = calendar.startOfDay(for: date(2025, 3, 3, in: calendar))...calendar.startOfDay(for: date(2025, 3, 9, in: calendar))
        XCTAssertEqual(data.activeDays(in: range), 2)

        let summary = text("en_US").summary(ActivityGridSummary(range: range, activeDays: 2))
        XCTAssertTrue(summary.hasPrefix("Activity, "))
        XCTAssertTrue(summary.hasSuffix("2 active days."))
    }

    func testValueFormatterAndEmptyDays() {
        let english = text("en_US")
        XCTAssertEqual(english.value(32, formatter: { "\(Int($0)) min" }), "32 min")
        XCTAssertEqual(english.value(nil, formatter: { _ in "unused" }), english.noActivity)
        XCTAssertEqual(english.value(0, formatter: nil), english.noActivity)
    }
}
