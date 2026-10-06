import Foundation

/// The package's default texts in the grid's language, plus the date formats they use.
///
/// The language comes from the grid's locale (the calendar passed to `activityGridCalendar`,
/// else the SwiftUI `locale` environment value), not from the device, so apps that switch
/// language in-app get matching texts. Languages without a translation fall back to English.
/// Every text here can be replaced by the host app through a modifier.
struct ActivityGridText {
    let locale: Locale
    private let bundle: Bundle
    private let calendar: Calendar

    init(calendar: Calendar) {
        let locale = calendar.locale ?? .current
        self.locale = locale
        self.calendar = calendar
        self.bundle = Self.localizedBundle(for: locale)
    }

    /// The `.lproj` folder of the package's resources for `locale`'s language, or English.
    ///
    /// Picking the folder ourselves is what makes the in-app locale win over the device language.
    /// When the String Catalog wasn't compiled into `.lproj` folders (plain `swift build`), the
    /// catalog keys are used as they are, which are the English texts.
    static func localizedBundle(for locale: Locale) -> Bundle {
        let language = locale.language.languageCode?.identifier ?? "en"
        for candidate in [language, "en"] {
            if let path = Bundle.module.path(forResource: candidate, ofType: "lproj"), let bundle = Bundle(path: path) {
                return bundle
            }
        }
        return .module
    }

    // MARK: Package strings

    var less: String {
        String(localized: "Less", bundle: bundle, locale: locale, comment: "Legend label before the lightest color.")
    }

    var more: String {
        String(localized: "More", bundle: bundle, locale: locale, comment: "Legend label after the darkest color.")
    }

    var noActivity: String {
        String(localized: "No activity", bundle: bundle, locale: locale, comment: "Value of a day without activity.")
    }

    /// "5 activities", or the host's formatter output.
    func value(_ value: Double?, formatter: ((Double) -> String)?) -> String {
        guard let value else { return noActivity }
        if let formatter { return formatter(value) }
        guard value > 0 else { return noActivity }
        if value.rounded() == value, let count = Int(exactly: value) {
            return String(localized: "\(count) activities", bundle: bundle, locale: locale, comment: "Default value text for a whole number.")
        }
        let number = value.formatted(.number.precision(.fractionLength(0...2)).locale(locale))
        return String(localized: "\(number) activities", bundle: bundle, locale: locale, comment: "Default value text for a fractional number.")
    }

    func level(_ level: Int, of count: Int) -> String {
        String(localized: "Level \(level) of \(count)", bundle: bundle, locale: locale, comment: "VoiceOver: intensity level of a day.")
    }

    func weekLabel(for weekStart: Date) -> String {
        let day = formatted(weekStart, template: "MMMMd")
        return String(localized: "Week of \(day)", bundle: bundle, locale: locale, comment: "VoiceOver: label of a week column.")
    }

    func tooltip(for date: Date, value: String) -> String {
        let day = mediumDate(date)
        return String(localized: "\(day) · \(value)", bundle: bundle, locale: locale, comment: "Tooltip text: date, then value.")
    }

    func summary(range: ClosedRange<Date>, activeDays: Int, statistics: ActivityStatistics) -> String {
        let formatter = DateIntervalFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = calendar.timeZone
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let interval = formatter.string(from: range.lowerBound, to: range.upperBound)

        var parts = [
            String(localized: "Activity, \(interval)", bundle: bundle, locale: locale, comment: "VoiceOver summary: the date range shown."),
            String(localized: "\(activeDays) active days", bundle: bundle, locale: locale, comment: "VoiceOver summary: days with activity."),
        ]
        if let current = statistics.currentStreak {
            parts.append(String(localized: "Current streak: \(current.length) days", bundle: bundle, locale: locale, comment: "VoiceOver summary: current streak length."))
        }
        if let longest = statistics.longestStreak {
            parts.append(String(localized: "Longest streak: \(longest.length) days", bundle: bundle, locale: locale, comment: "VoiceOver summary: longest streak length."))
        }
        return parts.joined(separator: ". ") + "."
    }

    // MARK: Dates (names come from the system, in any locale and calendar)

    /// "Tuesday, March 4, 2025"
    func fullDate(_ date: Date) -> String {
        formatted(date, template: "EEEEyMMMMd")
    }

    /// "Mar 4, 2025"
    func mediumDate(_ date: Date) -> String {
        let formatter = dateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// "Mar"
    func shortMonth(_ date: Date) -> String {
        formatted(date, template: "LLL")
    }

    /// Short weekday names indexed by `Calendar` weekday number minus one (Sunday first).
    var shortWeekdaySymbols: [String] {
        var calendar = calendar
        calendar.locale = locale
        return calendar.shortStandaloneWeekdaySymbols
    }

    private func formatted(_ date: Date, template: String) -> String {
        let formatter = dateFormatter()
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }

    private func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = calendar.timeZone
        return formatter
    }
}
