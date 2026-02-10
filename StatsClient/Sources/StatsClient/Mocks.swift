//
//  Mocks.swift
//  StatsClient
//
//  Created by Artem Novichkov on 09.02.2026.
//

import Foundation

extension StatsCache {
    public static var mockMultipleModels: StatsCache {
        let calendar = Calendar.current
        let today = Date()
        return StatsCache(
            version: 1,
            lastComputedDate: today,
            dailyActivity: [],
            dailyModelTokens: [],
            modelUsage: [
                "claude-opus-4-5-20251101": ModelUsage(
                    inputTokens: 150000,
                    outputTokens: 45000,
                    cacheReadInputTokens: 80000,
                    cacheCreationInputTokens: 20000,
                    webSearchRequests: 5,
                    costUSD: 2.45,
                    contextWindow: 200000,
                    maxOutputTokens: 16000
                ),
                "claude-sonnet-4-20250514": ModelUsage(
                    inputTokens: 250000,
                    outputTokens: 75000,
                    cacheReadInputTokens: 120000,
                    cacheCreationInputTokens: 30000,
                    webSearchRequests: 10,
                    costUSD: 1.85,
                    contextWindow: 200000,
                    maxOutputTokens: 16000
                ),
                "claude-haiku-3-5-20241022": ModelUsage(
                    inputTokens: 50000,
                    outputTokens: 15000,
                    cacheReadInputTokens: 25000,
                    cacheCreationInputTokens: 5000,
                    webSearchRequests: 2,
                    costUSD: 0.35,
                    contextWindow: 200000,
                    maxOutputTokens: 8192
                )
            ],
            totalSessions: 42,
            totalMessages: 567,
            longestSession: LongestSession(
                sessionId: "mock-session-123",
                duration: 7200,
                messageCount: 89,
                timestamp: calendar.date(byAdding: .day, value: -3, to: today)!
            ),
            firstSessionDate: calendar.date(byAdding: .day, value: -30, to: today)!,
            hourCounts: ["9": 10, "14": 25, "16": 15],
            totalSpeculationTimeSavedMs: 125000
        )
    }

    public static var mockNoActivity: StatsCache {
        let calendar = Calendar.current
        let today = Date()
        return StatsCache(
            version: 1,
            lastComputedDate: today,
            dailyActivity: [],
            dailyModelTokens: [],
            modelUsage: [:],
            totalSessions: 0,
            totalMessages: 0,
            longestSession: LongestSession(
                sessionId: "",
                duration: 0,
                messageCount: 0,
                timestamp: today
            ),
            firstSessionDate: today,
            hourCounts: [:],
            totalSpeculationTimeSavedMs: 0
        )
    }

    public static var mockEmptyHours: StatsCache {
        let calendar = Calendar.current
        let today = Date()
        return StatsCache(
            version: 1,
            lastComputedDate: today,
            dailyActivity: [],
            dailyModelTokens: [],
            modelUsage: [:],
            totalSessions: 10,
            totalMessages: 50,
            longestSession: LongestSession(
                sessionId: "mock",
                duration: 3600,
                messageCount: 20,
                timestamp: today
            ),
            firstSessionDate: calendar.date(byAdding: .day, value: -7, to: today)!,
            hourCounts: [:],
            totalSpeculationTimeSavedMs: 5000
        )
    }

    public static var mock: StatsCache {
        let calendar = Calendar.current
        let today = Date()

        let dailyActivity = (0..<14).map { daysAgo in
            DailyActivity(
                date: calendar.date(byAdding: .day, value: -daysAgo, to: today)!,
                messageCount: Int.random(in: 10...100),
                sessionCount: Int.random(in: 1...10),
                toolCallCount: Int.random(in: 5...50)
            )
        }.reversed()

        let dailyModelTokens = (0..<14).map { daysAgo in
            DailyModelTokens(
                date: calendar.date(byAdding: .day, value: -daysAgo, to: today)!,
                tokensByModel: [
                    "claude-sonnet-4-20250514": Int.random(in: 10000...50000),
                    "claude-haiku-4-20250514": Int.random(in: 5000...20000)
                ]
            )
        }

        var hourCounts: [String: Int] = [:]
        for hour in 0..<24 {
            hourCounts[String(hour)] = Int.random(in: 0...50)
        }

        return StatsCache(
            version: 1,
            lastComputedDate: today,
            dailyActivity: Array(dailyActivity),
            dailyModelTokens: dailyModelTokens,
            modelUsage: [
                "claude-opus-4-5-20251101": ModelUsage(
                    inputTokens: 150000,
                    outputTokens: 45000,
                    cacheReadInputTokens: 80000,
                    cacheCreationInputTokens: 20000,
                    webSearchRequests: 5,
                    costUSD: 2.45,
                    contextWindow: 200000,
                    maxOutputTokens: 16000
                )
            ],
            totalSessions: 42,
            totalMessages: 567,
            longestSession: LongestSession(
                sessionId: "mock-session-123",
                duration: 7200,
                messageCount: 89,
                timestamp: calendar.date(byAdding: .day, value: -3, to: today)!
            ),
            firstSessionDate: calendar.date(byAdding: .day, value: -30, to: today)!,
            hourCounts: hourCounts,
            totalSpeculationTimeSavedMs: 125000
        )
    }
}
