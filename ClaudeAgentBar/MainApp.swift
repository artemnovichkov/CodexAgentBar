import SwiftUI
import StatsClientLive
import StatsFeature

@main
struct MainApp: App {
    var body: some Scene {
        MenuBarExtra("ClaudeAgentBar", systemImage: "hammer.fill") {
            StatsView(viewModel: .init(statsClient: .happyPath))
        }
        .menuBarExtraStyle(.window)
    }
}
