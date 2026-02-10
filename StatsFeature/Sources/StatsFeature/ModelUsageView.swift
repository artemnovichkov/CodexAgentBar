import SwiftUI
import StatsClient

struct ModelUsageView: View {
    let stats: StatsCache

    var body: some View {
        VStack(spacing: 4) {
            ForEach(stats.modelUsage.keys.sorted(), id: \.self) { name in
                if let usage = stats.modelUsage[name] {
                    let totalTokens = usage.inputTokens + usage.cacheReadInputTokens + usage.cacheCreationInputTokens
                    HStack {
                        Text(shortModelName(name))
                            .font(.subheadline)
                        Spacer()
                        Text(totalTokens, format: .number.notation(.compactName))
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func shortModelName(_ name: String) -> String {
        let parts = name.split(separator: "-")
        guard parts.count >= 4, parts[0] == "claude" else { return name }
        let family = parts[1].capitalized
        let version = "\(parts[2]).\(parts[3])"
        return "\(family) \(version)"
    }
}

#Preview("Single model") {
    ModelUsageView(stats: .mock)
        .padding()
}

#Preview("Multiple models") {
    ModelUsageView(stats: .mockMultipleModels)
        .padding()
}
