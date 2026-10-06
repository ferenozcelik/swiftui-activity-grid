# Getting Started

Show a year of activity, let people tap a day, and style the grid for your app.

## Show your data

Pass a dictionary of values keyed by date. Only the calendar day of each date matters,
and several values on the same day are added up.

```swift
import SwiftUI
import SwiftUIActivityGrid

struct ProfileView: View {
    let minutesByDay: [Date: Double]

    var body: some View {
        ActivityGrid(minutesByDay)
    }
}
```

Your own model types work too. Conform them to ``ActivityEntry``:

```swift
extension Workout: ActivityEntry {
    var value: Double { Double(minutes) }
}

ActivityGrid(workouts, range: .lastMonths(6))
```

## Pick the days

The default range, ``ActivityGridRange/lastYear``, shows the current week and the
52 weeks before it, scrolled to today. Other ranges include
``ActivityGridRange/lastWeeks(_:)``, ``ActivityGridRange/year(_:)`` and
``ActivityGridRange/month(containing:)``.

To show every week without scrolling and size the cells to the width, use
``ActivityGridDisplayMode/fit``:

```swift
ActivityGrid(minutesByDay, range: .lastMonths(4))
    .activityGridDisplayMode(.fit)
```

## Respond to taps

Bind a selection to know which day is selected. Tapping a day selects it and shows a
tooltip; tapping it again clears the selection.

```swift
@State private var selectedDay: Date?

ActivityGrid(minutesByDay, selection: $selectedDay)
    .onActivityDayTap { day in
        print(day.date, day.value ?? 0)
    }
```

## Style it

Modifiers set the look for one grid, or for every grid inside a container:

```swift
ActivityGrid(minutesByDay)
    .activityGridStyle(.circles)
    .activityGridPalette(.viridis)
    .activityGridLevels(.quantile)
    .activityGridValueFormatter { "\(Int($0)) min" }
```

For a look of your own, write an ``ActivityGridStyle``.

## Calendars and time zones

The grid uses `Calendar.current` unless you pass a calendar. If your data was recorded
in UTC, pass a UTC calendar so late-evening entries stay on the right day:

```swift
var calendar = Calendar(identifier: .gregorian)
calendar.timeZone = .gmt
calendar.firstWeekday = 2 // Monday

ActivityGrid(minutesByDay)
    .activityGridCalendar(calendar)
```

## Lots of data

``ActivityGrid`` builds an ``ActivityGridData`` from a dictionary every time it updates.
That's quick for a year or two. With more, build the data once and keep it:

```swift
let data = ActivityGridData(minutesByDay, calendar: calendar)
ActivityGrid(data, range: .lastYear)
```
