import Foundation

/// Made-up activity that looks the same on every run.
enum SampleData {
    /// How many days in a row up to today have activity by default.
    static let recentRun = 23

    /// About `days` days of values ending today.
    ///
    /// Busier on weekdays, slow waves of busy and quiet weeks, a few rest weeks,
    /// and `recentRun` busy days in a row up to today.
    static func values(days: Int = 400, recentRun: Int = recentRun, seed: UInt64 = 7, now: Date = .now, calendar: Calendar = .current) -> [Date: Double] {
        var generator = SeededGenerator(seed: seed)
        var values: [Date: Double] = [:]
        let today = calendar.startOfDay(for: now)

        for offset in 0..<days {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let roll = Double.random(in: 0..<1, using: &generator)
            let noise = Double.random(in: 0.55...1.35, using: &generator)

            let weekday = calendar.component(.weekday, from: day)
            let isWeekend = weekday == 1 || weekday == 7
            let isRestWeek = (offset / 7) % 11 == 6
            // A slow wave between quiet (0.3) and busy (1.0) periods.
            let wave = 0.65 + 0.35 * sin(Double(offset) / 19)

            let chance: Double
            if offset < recentRun || (150..<181).contains(offset) {
                // Every day active: the recent run, and an older, longer one.
                chance = 1
            } else if offset == recentRun || offset == 149 || offset == 181 {
                chance = 0
            } else {
                chance = isRestWeek ? 0.12 : (isWeekend ? 0.4 : 0.82) * (0.6 + 0.4 * wave)
            }
            guard roll < chance else { continue }

            // The recent run gets busier towards today.
            let boost = offset < recentRun ? 0.7 + 0.5 * Double(recentRun - offset) / Double(recentRun) : 1
            let value = (12 * wave * noise * boost * (isWeekend ? 0.7 : 1)).rounded()
            values[day.addingTimeInterval(9 * 3600)] = min(max(value, 1), 14)
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
