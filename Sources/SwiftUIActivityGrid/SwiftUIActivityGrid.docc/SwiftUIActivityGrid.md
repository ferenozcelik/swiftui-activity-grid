# ``SwiftUIActivityGrid``

A heatmap of daily values for SwiftUI, like the contribution graph on a GitHub profile.

## Overview

``ActivityGrid`` draws one cell per day and colors it by how much happened that day.
You pass in the values; the grid stores nothing and makes no network calls.

Days are grouped in your calendar and time zone, styles work like `ButtonStyle`,
streaks and totals come built in, and every visible or spoken text can be replaced.

## Topics

### Essentials

- <doc:GettingStarted>
- ``ActivityGrid``
- ``ActivityGridRange``

### Data

- ``ActivityEntry``
- ``ActivityGridData``
- ``ActivityDay``

### Statistics

- ``ActivityStatistics``
- ``Streak``

### Colors and levels

- ``ActivityPalette``
- ``ActivityLevelMapping``
- ``LevelContext``

### Styles

- ``ActivityGridStyle``
- ``DefaultActivityGridStyle``
- ``ActivityGridCellConfiguration``
- ``ActivityGridMetrics``
- ``ActivityGridStyleContext``
- ``CellShape``
- ``EmptyCellStyle``
- ``SelectionIndicator``

### Layout and labels

- ``ActivityGridDisplayMode``
- ``MonthLabelVisibility``
- ``MonthLabelContext``
- ``WeekdayLabelVisibility``
- ``ActivityGridLegend``
- ``ActivityGridTooltip``
