import Foundation

public struct StatsCache: Codable, Sendable {
    public let version: Int
    public let lastComputedDate: Date
    public let dailyActivity: [DailyActivity]
    public let dailyModelTokens: [DailyModelTokens]
    public let modelUsage: [String: ModelUsage]
    public let totalSessions: Int
    public let totalMessages: Int
    public let longestSession: LongestSession
    public let firstSessionDate: Date
    public let hourCounts: [String: Int]
    public let totalSpeculationTimeSavedMs: Int?
}

public struct DailyActivity: Codable, Identifiable, Sendable {
    public let date: Date
    public let messageCount: Int
    public let sessionCount: Int
    public let toolCallCount: Int

    public var id: Date { date }

    public init(date: Date, messageCount: Int, sessionCount: Int, toolCallCount: Int) {
        self.date = date
        self.messageCount = messageCount
        self.sessionCount = sessionCount
        self.toolCallCount = toolCallCount
    }
}

public struct DailyModelTokens: Codable, Sendable {
    public let date: Date
    public let tokensByModel: [String: Int]
}

public struct ModelUsage: Codable, Sendable {
    public let inputTokens: Int
    public let outputTokens: Int
    public let cacheReadInputTokens: Int
    public let cacheCreationInputTokens: Int
    public let webSearchRequests: Int
    public let costUSD: Double
    public let contextWindow: Int?
    public let maxOutputTokens: Int?
}

public struct LongestSession: Codable, Sendable {
    public let sessionId: String
    public let duration: Int
    public let messageCount: Int
    public let timestamp: Date
}

extension JSONDecoder {
    public static let statsDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 with fractional seconds first
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            // Fallback to date-only format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            if let date = dateFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: \(dateString)"
            )
        }
        return decoder
    }()
}
