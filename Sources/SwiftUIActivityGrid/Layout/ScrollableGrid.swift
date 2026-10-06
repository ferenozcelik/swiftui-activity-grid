import SwiftUI

/// Fixed-size cells in a horizontal scroll view. Week columns are created lazily,
/// and month labels live in each column's header, so they are lazy too.
struct ScrollableGrid: View {
    let grid: ResolvedGrid
    let initialPosition: ActivityGridDisplayMode.InitialPosition
    let onTap: (ActivityDay) -> Void

    @Environment(\.activityGridMonthLabels) private var monthLabels
    /// One line of `.caption2` text. The month labels and the space above the weekday labels share
    /// this height so the weekday labels line up with their rows.
    @ScaledMetric(relativeTo: .caption2) private var monthHeaderHeight: CGFloat = 14
    /// Width of the scroll view, measured after the first layout pass. Zero until then.
    @State private var viewportWidth: CGFloat = 0

    private var metrics: ActivityGridMetrics { grid.metrics }
    private var columnHeight: CGFloat { 7 * metrics.cellSize + 6 * metrics.spacing }
    private var contentWidth: CGFloat {
        let count = CGFloat(grid.weeks.count)
        return count * metrics.cellSize + max(0, count - 1) * metrics.spacing
    }
    /// Short ranges that fit stay at the leading edge. Before the width is known, only ranges that are
    /// too long for any phone are assumed not to fit.
    private var contentFits: Bool {
        viewportWidth > 0 ? contentWidth <= viewportWidth : grid.weeks.count < 26
    }
    private var showsMonthLabels: Bool {
        if case .hidden = monthLabels.kind { return false }
        return true
    }

    var body: some View {
        HStack(alignment: .top, spacing: metrics.labelSpacing) {
            WeekdayLabelsView(grid: grid, rowHeight: metrics.cellSize, spacing: metrics.spacing, headerHeight: showsMonthLabels ? monthHeaderHeight : nil)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: metrics.spacing) {
                        ForEach(grid.weeks) { week in
                            VStack(alignment: .leading, spacing: metrics.labelSpacing) {
                                if showsMonthLabels {
                                    MonthLabelView(monthStart: week.monthLabel, grid: grid)
                                        .frame(width: metrics.cellSize, height: monthHeaderHeight, alignment: .leading)
                                }
                                WeekColumnView(week: week, grid: grid, onTap: onTap)
                                    .frame(width: metrics.cellSize, height: columnHeight)
                            }
                            .id(week.id)
                        }
                    }
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear { viewportWidth = geometry.size.width }
                            .onValueChange(of: geometry.size.width) { viewportWidth = geometry.size.width }
                    }
                )
                .modifier(DefaultTrailingAnchor(isEnabled: initialPosition == .today && grid.initialWeekID == grid.weeks.last?.id && !contentFits))
                .onAppear { scrollToInitialWeek(proxy) }
                .onValueChange(of: grid.initialWeekID) { scrollToInitialWeek(proxy) }
            }
        }
    }

    private func scrollToInitialWeek(_ proxy: ScrollViewProxy) {
        guard initialPosition == .today, let id = grid.initialWeekID else { return }
        proxy.scrollTo(id, anchor: .trailing)
        // Lazy columns may not be laid out on the first pass, so try once more on the next update.
        Task { @MainActor in
            proxy.scrollTo(id, anchor: .trailing)
        }
    }
}

/// Starts the scroll view at its trailing edge on iOS 17 and later, without a visible jump.
private struct DefaultTrailingAnchor: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        if isEnabled, #available(iOS 17, macOS 14, watchOS 10, visionOS 1, *) {
            content.defaultScrollAnchor(.trailing)
        } else {
            content
        }
    }
}
