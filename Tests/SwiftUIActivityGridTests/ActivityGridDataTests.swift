import XCTest
@testable import SwiftUIActivityGrid

final class ActivityGridDataTests: XCTestCase {
    func testSameDayValuesAreSummed() {
        let calendar = makeCalendar()
        let data = ActivityGridData([
            date(2025, 3, 4, 0, 5, in: calendar): 2,
            date(2025, 3, 4, 23, 55, in: calendar): 3,
            date(2025, 3, 5, 9, in: calendar): 1,
        ], calendar: calendar)

        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data.value(on: date(2025, 3, 4, in: calendar)), 5)
        XCTAssertEqual(data.value(on: date(2025, 3, 5, in: calendar)), 1)
        XCTAssertNil(data.value(on: date(2025, 3, 6, in: calendar)))
    }

    func testAggregations() {
        let calendar = makeCalendar()
        let entries = [
            TestEntry(date: date(2025, 3, 4, 8, in: calendar), value: 4),
            TestEntry(date: date(2025, 3, 4, 20, in: calendar), value: 1),
            TestEntry(date: date(2025, 3, 4, 12, in: calendar), value: 7),
        ]
        let day = date(2025, 3, 4, in: calendar)

        XCTAssertEqual(ActivityGridData(entries, calendar: calendar, aggregation: .sum).value(on: day), 12)
        XCTAssertEqual(ActivityGridData(entries, calendar: calendar, aggregation: .max).value(on: day), 7)
        XCTAssertEqual(ActivityGridData(entries, calendar: calendar, aggregation: .last).value(on: day), 1)
        XCTAssertEqual(ActivityGridData(entries, calendar: calendar, aggregation: .average).value(on: day), 4)
    }

    func testBadValuesAreDroppedOrClamped() {
        let calendar = makeCalendar()
        let data = ActivityGridData([
            date(2025, 3, 1, in: calendar): .nan,
            date(2025, 3, 2, in: calendar): .infinity,
            date(2025, 3, 3, in: calendar): -4,
            date(2025, 3, 4, in: calendar): 0,
        ], calendar: calendar)

        XCTAssertNil(data.value(on: date(2025, 3, 1, in: calendar)))
        XCTAssertNil(data.value(on: date(2025, 3, 2, in: calendar)))
        XCTAssertEqual(data.value(on: date(2025, 3, 3, in: calendar)), 0)
        XCTAssertEqual(data.value(on: date(2025, 3, 4, in: calendar)), 0)
        XCTAssertEqual(data.maxValue, 0)
    }

    func testTimeZoneDecidesTheDay() {
        // 23:30 UTC on March 4 is already March 5 in Tokyo.
        let utc = makeCalendar(timeZone: "UTC")
        let tokyo = makeCalendar(timeZone: "Asia/Tokyo")
        let timestamp = date(2025, 3, 4, 23, 30, in: utc)

        let utcData = ActivityGridData([timestamp: 1], calendar: utc)
        let tokyoData = ActivityGridData([timestamp: 1], calendar: tokyo)

        XCTAssertEqual(utcData.value(on: date(2025, 3, 4, in: utc)), 1)
        XCTAssertEqual(tokyoData.value(on: date(2025, 3, 5, in: tokyo)), 1)
        XCTAssertNil(tokyoData.value(on: date(2025, 3, 4, in: tokyo)))
    }

    func testDayWithoutMidnight() {
        // On 2018-11-04 São Paulo skipped from 00:00 to 01:00, so the day starts at 01:00.
        let calendar = makeCalendar(timeZone: "America/Sao_Paulo")
        let early = date(2018, 11, 4, 1, 30, in: calendar)
        let late = date(2018, 11, 4, 23, 0, in: calendar)
        let data = ActivityGridData([early: 1, late: 2], calendar: calendar)

        XCTAssertEqual(data.count, 1)
        XCTAssertEqual(data.value(on: early), 3)
        XCTAssertEqual(calendar.component(.hour, from: calendar.startOfDay(for: late)), 1)
        XCTAssertEqual(calendar.component(.day, from: calendar.addingDays(1, to: calendar.startOfDay(for: late))), 5)
    }
}
