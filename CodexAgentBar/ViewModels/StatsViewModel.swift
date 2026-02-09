import Foundation
import Observation

@Observable
final class StatsViewModel {

    private(set) var stats: StatsCache?
    private(set) var error: String?

    private var fileMonitor: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1

    private static let statsPath: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/stats-cache.json"
    }()

    init(loadOnInit: Bool = true) {
        if loadOnInit {
            loadStats()
            startMonitoring()
        }
    }

    func setError(_ message: String) {
        error = message
        stats = nil
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Computed Properties

    var daysSinceFirstSession: Int? {
        guard let firstDate = stats?.firstSessionDate else { return nil }
        return Calendar.current.dateComponents([.day], from: firstDate, to: Date()).day
    }

    var peakHourDate: Date? {
        guard let hourCounts = stats?.hourCounts,
              let maxEntry = hourCounts.max(by: { $0.value < $1.value }),
              let hour = Int(maxEntry.key) else { return nil }
        return Calendar.current.date(from: DateComponents(hour: hour))
    }

    var sortedModelNames: [String] {
        stats?.modelUsage.keys.sorted() ?? []
    }

    var recentDailyActivity: [DailyActivity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }
        let activities = stats?.dailyActivity ?? []

        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: weekStart)!
            if let match = activities.first(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
                return match
            }
            return DailyActivity(date: day, messageCount: 0, sessionCount: 0, toolCallCount: 0)
        }
    }

    var sortedHourCounts: [(hour: Int, count: Int)] {
        guard let hourCounts = stats?.hourCounts else { return [] }
        return hourCounts
            .compactMap { key, value in
                guard let hour = Int(key) else { return nil }
                return (hour: hour, count: value)
            }
            .sorted { $0.hour < $1.hour }
    }

    // MARK: - Loading

    func loadStats() {
        let path = Self.statsPath
        guard FileManager.default.fileExists(atPath: path) else {
            stats = nil
            error = "No stats file found"
            return
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            stats = try StatsCache.decode(from: data)
            error = nil
        } catch {
            self.error = "Unable to read stats"
            stats = nil
        }
    }

    // MARK: - File Monitoring

    private func startMonitoring() {
        let path = Self.statsPath
        fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor != -1 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: .main
        )

        source.setEventHandler { [weak self] in
            self?.loadStats()
        }

        source.setCancelHandler { [weak self] in
            guard let self else { return }
            close(self.fileDescriptor)
            self.fileDescriptor = -1
        }

        source.resume()
        fileMonitor = source
    }

    private func stopMonitoring() {
        fileMonitor?.cancel()
        fileMonitor = nil
    }

    // MARK: - Helpers

    func shortModelName(_ name: String) -> String {
        let parts = name.split(separator: "-")
        guard parts.count >= 4, parts[0] == "claude" else { return name }
        let family = parts[1].capitalized
        let version = "\(parts[2]).\(parts[3])"
        return "\(family) \(version)"
    }

    func formatTokenCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}
