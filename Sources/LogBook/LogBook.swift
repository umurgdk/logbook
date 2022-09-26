import Foundation

public final class LogBook {
    public let persistance: LogPersistance
    public init(persistance: LogPersistance) {
        self.persistance = persistance
    }

    public init(logs: [Log]) {
        self.persistance = ReaderPersistance(logs: logs)
    }

    public func logs() async -> [Log] {
        await persistance.read()
    }

    public func makeLogger(_ category: String, in module: String) -> Logger {
        Logger(writer: persistance, category: category, module: module)
    }

    public func withExportedLogFile() async throws -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "Y-MM-dd-HH-mm-ss"
        let date = formatter.string(from: Date())
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("logs-\(date).json")
        let task = Task.detached {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

            let logs = await self.logs()
            let data = try encoder.encode(logs)

            try data.write(to: url)
        }

        try await task.value

        return url
    }
}

public protocol LogWriter {
    func write(_ log: Log)
}

public protocol LogReader {
    func read() async -> [Log]
}

public typealias LogPersistance = LogReader & LogWriter

public final class InMemoryPersistance: LogPersistance {
    private var logs: [Log] = []
    public init() { }

    public func write(_ log: Log) {
        logs.append(log)
    }

    public func read() async -> [Log] {
        logs
    }
}

final class ReaderPersistance: LogPersistance {
    let logs: [Log]
    init(logs: [Log]) {
        self.logs = logs
    }

    func read() async -> [Log] {
        logs
    }

    func write(_ log: Log) { }
}

public protocol LogDisplayer {
    associatedtype Output
    func display(log: Log) -> Output
}

public struct TextLogDisplayer: LogDisplayer {
    public func display(log: Log) -> String {
        "[\(log.module).\(log.category)][\(level(log.level))] \(log.message)"
    }

    private func level(_ level: Log.Level) -> String {
        switch level {
        case .error: return "ERROR"
        case .info: return "INFO"
        }
    }
}
