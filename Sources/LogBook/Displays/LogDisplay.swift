import Foundation

public protocol LogDisplay {
    associatedtype Output
    func display(log: Log) -> Output
}

