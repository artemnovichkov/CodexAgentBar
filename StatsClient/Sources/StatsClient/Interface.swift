//
//  StatsClient.swift
//  StatsClient
//
//  Created by Artem Novichkov on 09.02.2026.
//

import Foundation

public struct StatsClient: Sendable {
    public enum Error: Swift.Error {
        case fileNotFound
    }

    public static var statsPath: String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/stats-cache.json"
    }

    public var loadStats: @Sendable () throws -> StatsCache?
    public var startMonitoring: @Sendable (@escaping @Sendable () -> Void) -> DispatchSourceFileSystemObject?

    public init(
        loadStats: @escaping @Sendable () throws -> StatsCache?,
        startMonitoring: @escaping @Sendable (@escaping @Sendable () -> Void) -> DispatchSourceFileSystemObject?
    ) {
        self.loadStats = loadStats
        self.startMonitoring = startMonitoring
    }
}

extension StatsClient {
    public static var empty: StatsClient {
        StatsClient(
            loadStats: { throw Error.fileNotFound },
            startMonitoring: { _ in nil }
        )
    }

    public static var happyPath: StatsClient {
        StatsClient(
            loadStats: { .mock },
            startMonitoring: { _ in nil }
        )
    }
}
