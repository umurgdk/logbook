import Foundation

public protocol LogMessage: Codable {
    var hint: Log.Hint { get }
}

public protocol LogMessageProvider {
    associatedtype MessageType: LogMessage
    var logMessage: MessageType { get }
}
