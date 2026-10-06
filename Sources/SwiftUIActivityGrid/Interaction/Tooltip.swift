import SwiftUI

/// Carries the bounds of the selected cell up to the grid, which draws the tooltip over it.
struct SelectedCellAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? { nil }

    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

/// The tooltip bubble, placed above the selected cell (or below it near the top) and kept
/// inside the grid's bounds.
struct TooltipOverlay: View {
    let anchor: Anchor<CGRect>
    let day: ActivityDay
    let tooltip: ActivityGridTooltip
    let grid: ResolvedGrid
    let valueFormatter: (@MainActor @Sendable (Double) -> String)?

    var body: some View {
        GeometryReader { proxy in
            if let content {
                TooltipLayout(target: proxy[anchor]) {
                    content
                        .font(.caption)
                        .foregroundStyle(.background)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.primary.opacity(0.9), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .fixedSize()
                }
            }
        }
        // The selected day already reads its date and value to VoiceOver, and the bubble
        // must never take taps away from the cells under it.
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private var content: AnyView? {
        switch tooltip.kind {
        case .hidden:
            return nil
        case .custom(let content):
            return content(day)
        case .automatic:
            let value = grid.text.value(day.value, formatter: valueFormatter)
            return AnyView(Text(grid.text.tooltip(for: day.date, value: value)))
        }
    }
}

/// Places one subview centered above `target`, flipped below it when there's no room above,
/// and shifted sideways to stay within the bounds.
private struct TooltipLayout: Layout {
    let target: CGRect
    let gap: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let bubble = subviews.first else { return }
        let size = bubble.sizeThatFits(.unspecified)
        let maxX = max(bounds.width - size.width, 0)
        let x = min(max(target.midX - size.width / 2, 0), maxX)
        var y = target.minY - gap - size.height
        if y < 0 {
            y = target.maxY + gap
        }
        bubble.place(at: CGPoint(x: bounds.minX + x, y: bounds.minY + y), anchor: .topLeading, proposal: ProposedViewSize(size))
    }
}
