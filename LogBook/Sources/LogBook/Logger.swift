import Foundation

public struct Logger {
    public let category: String
    public let module: String

    private let writer: LogWriter
    public init(writer: LogWriter, category: String, module: String) {
        self.writer = writer
        self.category = category
        self.module = module
    }

    private func log(_ message: String, level: Log.Level, hint: Log.Hint = .text) -> Log {
        Log(
            level: level,
            module: module,
            category: category,
            message: message.data(using: .utf8) ?? Data(),
            hint: hint
        )
    }

    public func log<M: LogMessage>(_ message: M, level: Log.Level) {
        let data = (try? JSONEncoder().encode(message)) ?? "Couldn't encode the log message".data(using: .utf8)!
        let log = Log(
            level: level,
            module: module,
            category: category,
            message: data,
            hint: message.hint
        )

        writer.write(log)
    }

    public func info(_ message: String) {
        writer.write(log(message, level: .info))
    }

    public func info<M: LogMessage>(_ message: M) {
        log(message, level: .info)
    }

    public func info<MP: LogMessageProvider>(_ messageProvider: MP) {
        let message = messageProvider.logMessage
        log(message, level: .info)
    }

    public func error(_ message: String) {
        writer.write(log(message, level: .error))
    }

    public func error<M: LogMessage>(_ message: M) {
        log(message, level: .error)
    }

    public func error<MP: LogMessageProvider>(_ messageProvider: MP) {
        let message = messageProvider.logMessage
        log(message, level: .error)
    }
}
