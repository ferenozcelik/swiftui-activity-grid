# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org). Before 1.0, minor versions may change the API.

## [0.1.1] - 2026-10-06

### Changed

- Empty cells in the built-in dark palettes are lighter, so they are visible on dark cards.

## [0.1.0] - 2026-10-06

First public preview.

### Added

- `ActivityGrid` view for `[Date: Double]`, `ActivityEntry` collections and `ActivityGridData`.
- Ranges: last days, weeks, months and year; a calendar year; a month; custom dates.
- Days grouped in any calendar and time zone. `sum`, `max`, `last` and `average` aggregation.
- `ActivityGridStyle` protocol and `DefaultActivityGridStyle` with `.automatic`, `.squares`, `.rounded`, `.circles` and `.minimal`.
- Palettes: green, blue, orange, purple, viridis and monochrome, with light and dark colors. Opacity and gradient palettes.
- Level mappings: linear, quantile, thresholds and custom.
- Scrollable mode that starts at today. Fit mode that sizes the cells to the space.
- Month labels, weekday labels and a legend. Each can be hidden or replaced.
- Tap to select, a selection binding and a tooltip.
- `ActivityStatistics`: current streak, longest streak, active days, total and best day.
- Example app with showcase pages and a playground.
- Privacy manifest with no data collection.

[0.1.1]: https://github.com/ferenozcelik/swiftui-activity-grid/releases/tag/0.1.1
[0.1.0]: https://github.com/ferenozcelik/swiftui-activity-grid/releases/tag/0.1.0
