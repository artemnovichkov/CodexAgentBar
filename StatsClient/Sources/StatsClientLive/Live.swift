import Foundation
import StatsClient

extension StatsClient {
    public static var live: StatsClient {
        StatsClient(
            loadStats: {
                guard FileManager.default.fileExists(atPath: statsPath) else {
                    throw Error.fileNotFound
                }
                let data = try Data(contentsOf: URL(fileURLWithPath: statsPath))
                return try JSONDecoder.statsDecoder.decode(StatsCache.self, from: data)
            },
            startMonitoring: { eventHandler in
                let path = Self.statsPath
                var fileDescriptor = open(path, O_EVTONLY)
                if fileDescriptor == -1 {
                    return nil
                }

                let source = DispatchSource.makeFileSystemObjectSource(
                    fileDescriptor: fileDescriptor,
                    eventMask: .write,
                    queue: .main
                )

                source.setEventHandler(handler: eventHandler)

                source.setCancelHandler {
                    close(fileDescriptor)
                    fileDescriptor = -1
                }

                source.resume()
                return source
            }
        )
    }
}

extension JSONDecoder {
    public static let statsDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .gmt
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
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
