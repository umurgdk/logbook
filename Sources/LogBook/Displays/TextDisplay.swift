import Foundation

public struct TextDisplay: LogDisplay {
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

public extension LogDisplay where Self == TextDisplay {
    static var text: Self { TextDisplay() }
}
