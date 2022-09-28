import SwiftUI
import LogBook

public struct LogBookEnvironmentKey: EnvironmentKey {
    public static let defaultValue = LogBook(persistence: .inMemory())
}

public struct LoggerEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Logger = LogBookEnvironmentKey.defaultValue.makeLogger("Default", in: "Default")
}

public extension EnvironmentValues {
    var logBook: LogBook {
        get { self[LogBookEnvironmentKey.self] }
        set { self[LogBookEnvironmentKey.self] = newValue }
    }

    var logger: Logger {
        get { self[LoggerEnvironmentKey.self] }
        set { self[LoggerEnvironmentKey.self] = newValue }
    }
}
