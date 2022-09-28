import SwiftUI
import LogBook

public struct SwiftUIDisplay: LogDisplay {
    public func display(log: Log) -> some View {
        LogView(log: log)
    }
}

public extension LogDisplay where Self == SwiftUIDisplay {
    static var swiftUI: some LogDisplay { SwiftUIDisplay() }
}
