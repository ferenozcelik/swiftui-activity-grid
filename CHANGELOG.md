# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org). Before 1.0, minor versions may change the API.

## [0.1.0] - Unreleased

First public preview.

### Added

- `ActivityGrid` view for `[Date: Double]`, `ActivityEntry` collections and prebuilt `ActivityGridData`.
- Ranges: last days, weeks, months and year; a calendar year; a month; a custom date range.
- Day grouping in any calendar and time zone, including DST days, with `sum`, `max`, `last` and `average` aggregation.
- `ActivityGridStyle` protocol and `DefaultActivityGridStyle` with `.automatic`, `.github`, `.rounded`, `.circles` and `.minimal` presets.
- Palettes: green, blue, orange, purple, viridis and monochrome with light and dark colors; opacity and gradient palettes.
- Level mappings: linear, quantile, thresholds and custom.
- Scrollable mode with lazy week columns that starts at today, and a fit mode that sizes cells to the space.
- Month and weekday labels and a legend, each of which can be hidden or replaced.
- Tap to select, a selection binding and a tooltip.
- `ActivityStatistics`: current streak (today doesn't break it until it's over), longest streak, active days, total and best day.
- VoiceOver: a summary of the grid, week groups and a label and value for each day, all replaceable.
- English and Turkish texts, following the grid's locale instead of the device language.
- Privacy manifest with no data collection.

[0.1.0]: https://github.com/ferenozcelik/swiftui-activity-grid/releases/tag/0.1.0
