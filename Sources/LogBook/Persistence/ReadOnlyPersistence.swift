import Foundation

public final class ReadOnlyPersistance: LogPersistence {
    let logs: [Log]
    init(logs: [Log]) {
        self.logs = logs
    }

    public func read() async -> [Log] {
        logs
    }

    public func write(_ log: Log) { }
}

public extension LogPersistence where Self == ReadOnlyPersistance {
    static func readonly(logs: [Log]) -> ReadOnlyPersistance {
        ReadOnlyPersistance(logs: logs)
    }
}
