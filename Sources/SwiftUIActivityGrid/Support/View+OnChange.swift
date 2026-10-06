import SwiftUI

extension View {
    /// `onChange(of:)` without the deprecation warning on newer systems, keeping iOS 16 support.
    @ViewBuilder
    func onValueChange<V: Equatable>(of value: V, perform action: @escaping () -> Void) -> some View {
        #if os(visionOS)
        onChange(of: value) { action() }
        #else
        if #available(iOS 17, macOS 14, watchOS 10, *) {
            onChange(of: value) { action() }
        } else {
            onChange(of: value) { _ in action() }
        }
        #endif
    }
}
