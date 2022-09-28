import SwiftUI
import LogBook

enum MessageView {
    @ViewBuilder
    static func from(log: Log) -> some View {
        let data = log.message

        switch log.hint {
        case .text:
            Text(String(data: data, encoding: .utf8) ?? "N/A")
                .font(.system(.caption, design: .monospaced))
                .padding([.horizontal, .bottom])

        case .request:
            if let request = try? JSONDecoder().decode(URLRequestMessage.self, from: data) {
                RequestMessageView(request: request)
            } else {
                Text(String(data: data, encoding: .utf8) ?? "N/A")
                    .font(.system(.caption, design: .monospaced))
                    .padding([.horizontal, .bottom])
            }

        case .response:
            if let response = try? JSONDecoder().decode(URLResponseMessage.self, from: data) {
                ResponseMessageView(response: response)
            } else {
                Text(String(data: data, encoding: .utf8) ?? "N/A")
                    .font(.system(.caption, design: .monospaced))
                    .padding([.horizontal, .bottom])
            }
        }
    }
}
