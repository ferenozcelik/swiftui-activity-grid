import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if let card = UserDefaults.standard.string(forKey: "screenshotCard") {
                    // Launch with `-screenshotCard "Default"` to show a single Gallery card.
                    GalleryView(only: card)
                } else {
                    ExampleList()
                }
            }
        }
    }
}

struct ExampleList: View {
    var body: some View {
        List {
            Section("Examples") {
                NavigationLink("Gallery") { GalleryView() }
                NavigationLink("Playground") { PlaygroundView() }
            }
        }
        .navigationTitle("ActivityGrid")
    }
}
