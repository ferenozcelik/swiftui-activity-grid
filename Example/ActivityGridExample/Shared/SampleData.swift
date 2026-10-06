import Foundation

/// Made-up activity that looks the same on every run.
enum SampleData {
    /// About `days` days of values ending today: busier on weekdays, some quiet weeks,
    /// and a streak running up to yesterday.
    static func values(days: Int = 400, seed: UInt64 = 7, now: Date = .now, calendar: Calendar = .current) -> [Date: Double] {
        var generator = SeededGenerator(seed: seed)
        var values: [Date: Double] = [:]
        let today = calendar.startOfDay(for: now)

        for offset in 1..<days {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: day)
            let isWeekend = weekday == 1 || weekday == 7
            let isQuietWeek = (offset / 7) % 9 == 4
            let chance = offset <= 12 ? 1.0 : (isQuietWeek ? 0.15 : (isWeekend ? 0.35 : 0.75))
            guard Double.random(in: 0..<1, using: &generator) < chance else { continue }
            values[day.addingTimeInterval(9 * 3600)] = Double(Int.random(in: 1...12, using: &generator))
        }
        return values
    }
}

/// A tiny linear congruential generator, so the sample data is stable between runs.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state
    }
}
