# Contributing

Thanks for helping out. Bug reports, fixes and ideas are all welcome.

## Getting set up

1. Clone the repository and open `SwiftUIActivityGrid.xcworkspace` in Xcode 16 or later.
2. Run the **ActivityGridExample** scheme to try your change in the example pages and the playground.
3. Run the tests with `swift test`, or with **Product → Test** on the **SwiftUIActivityGrid** scheme.
   The text tests only run in Xcode, because `swift test` doesn't compile the String Catalog.

## Ground rules

- **No dependencies.** The package must stay free of third-party code.
- **No global state.** Configuration goes through the SwiftUI environment, never through singletons or static variables.
- **No hidden "now".** Pure logic takes the current date and the calendar as parameters.
- **Calendar maths through `Calendar`.** Use `calendar.date(byAdding: .day, ...)` and `startOfDay(for:)`. Never add 86 400 seconds.
- **Every new visible or spoken text needs a default and a way to replace it.** Add the English text to
  `Resources/Localizable.xcstrings`, and give host apps a modifier or parameter to supply their own.
- **iOS 16 first.** Newer APIs go behind `#available` with a fallback.
- **Tests stay light.** Test pure logic (data, layout, levels, texts). Tests must not touch the pasteboard or other system services.
- Public API needs `///` documentation.

## Pull requests

- Keep each pull request to one topic.
- Describe what changed and how you checked it, including screenshots for visual changes.
