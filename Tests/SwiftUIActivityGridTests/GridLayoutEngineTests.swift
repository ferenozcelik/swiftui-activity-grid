import XCTest
@testable import SwiftUIActivityGrid

final class GridLayoutEngineTests: XCTestCase {
    func testLastYearIsFiftyThreeWeeksEndingToday() {
        let calendar = makeCalendar()
        let now = date(2025, 3, 5, in: calendar) // a Wednesday
        let layout = GridLayoutEngine.layout(range: .lastYear, calendar: calendar, now: now)

        XCTAssertEqual(layout.weeks.count, 53)
        XCTAssertEqual(layout.todayWeekIndex, 52)
        let lastWeek = layout.weeks[52].cells
        XCTAssertEqual(lastWeek.filter(\.isInRange).count, 3) // Mon, Tue, Wed
        XCTAssertTrue(lastWeek[2].isToday)
        XCTAssertTrue(lastWeek[3].isFuture)
        XCTAssertFalse(lastWeek[3].isInRange)
    }

    func testWeekStartFollowsFirstWeekday() {
        let monday = makeCalendar(firstWeekday: 2)
        let sunday = makeCalendar(firstWeekday: 1)
        let now = date(2025, 3, 5, in: monday)

        let mondayLayout = GridLayoutEngine.layout(range: .lastWeeks(2), calendar: monday, now: now)
        let sundayLayout = GridLayoutEngine.layout(range: .lastWeeks(2), calendar: sunday, now: now)

        XCTAssertEqual(mondayLayout.weekdays, [2, 3, 4, 5, 6, 7, 1])
        XCTAssertEqual(sundayLayout.weekdays, [1, 2, 3, 4, 5, 6, 7])
        XCTAssertEqual(monday.component(.weekday, from: mondayLayout.weeks[0].start), 2)
        XCTAssertEqual(sunday.component(.weekday, from: sundayLayout.weeks[0].start), 1)
    }

    func testPartialWeeksMarkOutOfRangeDays() {
        let calendar = makeCalendar()
        // March 2025 starts on a Saturday and ends on a Monday.
        let layout = GridLayoutEngine.layout(range: .month(containing: date(2025, 3, 15, in: calendar)), calendar: calendar, now: date(2025, 6, 1, in: calendar))

        XCTAssertEqual(layout.weeks.count, 6)
        XCTAssertEqual(layout.weeks[0].cells.map(\.isInRange), [false, false, false, false, false, true, true])
        XCTAssertEqual(layout.weeks[5].cells.map(\.isInRange), [true, false, false, false, false, false, false])
        XCTAssertEqual(layout.weeks.flatMap(\.cells).filter(\.isInRange).count, 31)
    }

    func testYearShapes() {
        let calendar = makeCalendar(firstWeekday: 2)
        let now = date(2026, 1, 1, in: calendar)

        // 2024 is a leap year starting on a Monday: 53 columns.
        let year2024 = GridLayoutEngine.layout(range: .year(2024), calendar: calendar, now: now)
        XCTAssertEqual(year2024.weeks.count, 53)
        XCTAssertEqual(year2024.weeks.flatMap(\.cells).filter(\.isInRange).count, 366)

        // 2012 is a leap year starting on a Sunday: its first and last days sit in their own weeks.
        let year2012 = GridLayoutEngine.layout(range: .year(2012), calendar: calendar, now: now)
        XCTAssertEqual(year2012.weeks.count, 54)
    }

    func testMonthLabelAnchors() {
        let calendar = makeCalendar()
        let range = ActivityGridRange.custom(date(2025, 1, 1, in: calendar)...date(2025, 4, 30, in: calendar))
        let layout = GridLayoutEngine.layout(range: range, calendar: calendar, now: date(2025, 6, 1, in: calendar))
        let labels = layout.weeks.enumerated().compactMap { index, week in
            week.monthLabel.map { (index, calendar.component(.month, from: $0)) }
        }

        XCTAssertEqual(labels.map(\.1), [1, 2, 3, 4])
        XCTAssertEqual(labels.first?.0, 0)
        // Each label sits in the column holding the first day of its month.
        for (index, month) in labels {
            let firstDay = layout.weeks[index].cells.first { $0.isInRange && calendar.component(.day, from: $0.date) == 1 }
            XCTAssertEqual(firstDay.map { calendar.component(.month, from: $0.date) }, month)
        }
    }

    func testPartialFirstMonthLabelGivesWayToNextMonth() {
        let calendar = makeCalendar()
        let range = ActivityGridRange.custom(date(2025, 1, 25, in: calendar)...date(2025, 3, 31, in: calendar))
        let layout = GridLayoutEngine.layout(range: range, calendar: calendar, now: date(2025, 6, 1, in: calendar))
        let months = layout.weeks.compactMap(\.monthLabel).map { calendar.component(.month, from: $0) }

        XCTAssertEqual(months, [2, 3])
    }

    func testEveryDayAppearsOnceAcrossDST() {
        let calendar = makeCalendar(timeZone: "America/Sao_Paulo")
        let range = ActivityGridRange.custom(date(2018, 10, 20, in: calendar)...date(2018, 11, 20, in: calendar))
        let layout = GridLayoutEngine.layout(range: range, calendar: calendar, now: date(2019, 1, 1, in: calendar))
        let keys = layout.weeks.flatMap(\.cells).filter(\.isInRange).map(\.key)

        XCTAssertEqual(keys.count, 32)
        XCTAssertEqual(Set(keys).count, 32)
        XCTAssertEqual(keys, keys.sorted())
    }
}
