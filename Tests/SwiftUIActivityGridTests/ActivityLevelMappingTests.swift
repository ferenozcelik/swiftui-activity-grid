import XCTest
@testable import SwiftUIActivityGrid

final class ActivityLevelMappingTests: XCTestCase {
    private func context(_ values: [Double], levels: Int = 4) -> LevelContext {
        LevelContext(levelCount: levels, sortedPositiveValues: values.filter { $0 > 0 }.sorted())
    }

    func testEmptyAndZeroAreAlwaysLevelZero() {
        let context = context([1, 2, 3])
        for mapping in [ActivityLevelMapping.linear, .quantile, .thresholds([1, 5]), .custom { _, _ in 3 }] {
            XCTAssertEqual(mapping.level(for: nil, context: context), 0)
            XCTAssertEqual(mapping.level(for: 0, context: context), 0)
        }
    }

    func testLinearBoundaries() {
        let context = context([20])
        let mapping = ActivityLevelMapping.linear

        XCTAssertEqual(mapping.level(for: 0.1, context: context), 1)
        XCTAssertEqual(mapping.level(for: 5, context: context), 1)
        XCTAssertEqual(mapping.level(for: 5.1, context: context), 2)
        XCTAssertEqual(mapping.level(for: 20, context: context), 4)
        XCTAssertEqual(mapping.level(for: 500, context: context), 4)
        XCTAssertEqual(ActivityLevelMapping.linear(max: 40).level(for: 20, context: context), 2)
    }

    func testThresholds() {
        let context = context([30])
        let mapping = ActivityLevelMapping.thresholds([1, 5, 10, 20])

        XCTAssertEqual(mapping.level(for: 0.5, context: context), 1)
        XCTAssertEqual(mapping.level(for: 4.9, context: context), 1)
        XCTAssertEqual(mapping.level(for: 5, context: context), 2)
        XCTAssertEqual(mapping.level(for: 19, context: context), 3)
        XCTAssertEqual(mapping.level(for: 20, context: context), 4)
        XCTAssertEqual(mapping.level(for: 30, context: context), 4)
    }

    func testQuantileSpreadsValuesAndKeepsTiesTogether() {
        let mapping = ActivityLevelMapping.quantile
        let spread = context([1, 2, 3, 100])
        XCTAssertEqual([1, 2, 3, 100].map { mapping.level(for: $0, context: spread) }, [1, 2, 3, 4])

        let ties = context([2, 2, 2, 2, 9])
        let tied = [2.0, 2, 2, 2].map { mapping.level(for: $0, context: ties) }
        XCTAssertEqual(Set(tied).count, 1)
        XCTAssertEqual(mapping.level(for: 9, context: ties), 4)
    }

    func testSingleValueAndAllZeroData() {
        let single = context([7])
        XCTAssertEqual(ActivityLevelMapping.linear.level(for: 7, context: single), 4)
        XCTAssertEqual(ActivityLevelMapping.quantile.level(for: 7, context: single), 4)

        let allZero = context([0, 0])
        XCTAssertEqual(allZero.maxValue, 0)
        XCTAssertEqual(ActivityLevelMapping.linear.level(for: 0, context: allZero), 0)
        XCTAssertEqual(ActivityLevelMapping.quantile.level(for: 0, context: allZero), 0)
    }

    func testCustomIsClamped() {
        let context = context([1])
        XCTAssertEqual(ActivityLevelMapping.custom { _, _ in 99 }.level(for: 1, context: context), 4)
        XCTAssertEqual(ActivityLevelMapping.custom { _, _ in -3 }.level(for: 1, context: context), 1)
    }
}
