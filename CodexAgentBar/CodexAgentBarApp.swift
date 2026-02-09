import SwiftUI

@main
struct CodexAgentBarApp: App {
    var body: some Scene {
        MenuBarExtra("CodexAgentBar", systemImage: "hammer.fill") {
            StatsView()
        }
        .menuBarExtraStyle(.window)
    }
}
