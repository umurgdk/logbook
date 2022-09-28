import Foundation

public final class LogBook {
    public let persistence: LogPersistence
    public init(persistence: LogPersistence = .inMemory()) {
        self.persistence = persistence
    }

    public func logs() async -> [Log] {
        await persistence.read()
    }

    public func makeLogger(_ category: String, in module: String) -> Logger {
        Logger(writer: persistence, category: category, module: module)
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
