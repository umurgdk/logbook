import Foundation

public final class InMemoryPersistance: LogPersistence {
    private var logs: [Log] = []
    private let limit: Int
    private let purgeCount: Int
    internal init(limit: Int = 5000, purgeCount: Int = 1000) {
        self.limit = limit
        self.purgeCount = purgeCount
    }

    public func write(_ log: Log) {
        logs.append(log)
        if logs.count > limit {
            logs = Array(logs.dropFirst(purgeCount))
        }
    }

    public func read() async -> [Log] {
        logs
    }
}

public extension LogPersistence where Self == InMemoryPersistance {
    static func inMemory(limit: Int = 5000, purgeCount: Int = 1000) -> Self {
        InMemoryPersistance(limit: limit, purgeCount: purgeCount)
    }
}
