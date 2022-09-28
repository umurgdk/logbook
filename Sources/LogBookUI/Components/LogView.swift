import SwiftUI
import LogBook

public struct LogView: View {
    public let log: Log
    public init(log: Log) {
        self.log = log
    }

    var color: Color {
        switch log.level {
        case .error: return .red
        case .info: return .secondary
        }
    }

    var title: String {
        switch log.level {
        case .info: return "INFO"
        case .error: return "ERROR"
        }
    }

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        return f
    }()

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(log.module).\(log.category)")
                    .foregroundColor(color)
                    .font(.caption)

                Spacer()

                Text("\(log.createdAt, formatter: Self.dateFormatter)")
                    .foregroundColor(.secondary)
                    .font(.caption2)
            }.padding()

            MessageView.from(log: log)
        }
    }
}
