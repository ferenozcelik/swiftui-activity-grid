import XCTest
@testable import SwiftUIActivityGrid

final class ActivityStatisticsTests: XCTestCase {
    private let calendar = makeCalendar()

    private func data(_ days: [(Int, Int, Double)]) -> ActivityGridData {
        var values: [Date: Double] = [:]
        for (month, day, value) in days {
            values[date(2025, month, day, in: calendar)] = value
        }
        return ActivityGridData(values, calendar: calendar)
    }

    func testCurrentStreakCountsYesterdayWhenTodayIsEmpty() {
        let data = data([(3, 1, 1), (3, 2, 2), (3, 3, 1)])

        let morningAfter = ActivityStatistics(data, now: date(2025, 3, 4, 9, in: calendar))
        XCTAssertEqual(morningAfter.currentStreak?.length, 3)
        XCTAssertEqual(morningAfter.currentStreak?.end, calendar.startOfDay(for: date(2025, 3, 3, in: calendar)))

        let sameDay = ActivityStatistics(data, now: date(2025, 3, 3, 9, in: calendar))
        XCTAssertEqual(sameDay.currentStreak?.length, 3)

        let twoDaysLater = ActivityStatistics(data, now: date(2025, 3, 5, 9, in: calendar))
        XCTAssertNil(twoDaysLater.currentStreak)
    }

    func testZeroBreaksAStreak() {
        let data = data([(3, 1, 1), (3, 2, 0), (3, 3, 1), (3, 4, 1)])
        let stats = ActivityStatistics(data, now: date(2025, 3, 4, in: calendar))

        XCTAssertEqual(stats.currentStreak?.length, 2)
        XCTAssertEqual(stats.activeDays, 3)
    }

    func testLongestStreakAcrossMonthsAndTotals() {
        let data = data([(1, 30, 1), (1, 31, 4), (2, 1, 2), (2, 2, 1), (2, 10, 4), (2, 11, 1)])
        let stats = ActivityStatistics(data, now: date(2025, 3, 1, in: calendar))

        XCTAssertEqual(stats.longestStreak?.length, 4)
        XCTAssertEqual(stats.longestStreak?.start, calendar.startOfDay(for: date(2025, 1, 30, in: calendar)))
        XCTAssertNil(stats.currentStreak)
        XCTAssertEqual(stats.total, 13)
        XCTAssertEqual(stats.bestDay?.value, 4)
        XCTAssertEqual(stats.bestDay?.date, calendar.startOfDay(for: date(2025, 1, 31, in: calendar)))
        XCTAssertEqual(stats.activeDays(in: .month(containing: date(2025, 2, 1, in: calendar))), 4)
    }

    func testFutureDaysDontExtendTheCurrentStreak() {
        let data = data([(3, 3, 1), (3, 4, 1), (3, 6, 1)])
        let stats = ActivityStatistics(data, now: date(2025, 3, 4, in: calendar))

        XCTAssertEqual(stats.currentStreak?.length, 2)
    }

    func testEmptyData() {
        let stats = ActivityStatistics(ActivityGridData([:], calendar: calendar), now: date(2025, 3, 4, in: calendar))

        XCTAssertNil(stats.currentStreak)
        XCTAssertNil(stats.longestStreak)
        XCTAssertNil(stats.bestDay)
        XCTAssertEqual(stats.activeDays, 0)
        XCTAssertEqual(stats.total, 0)
    }
}
