import Foundation

public protocol LogWriter {
    func write(_ log: Log)
}

public protocol LogReader {
    func read() async -> [Log]
}

public protocol LogPersistence: LogWriter, LogReader { }

