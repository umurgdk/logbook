import SwiftUI
import LogBook

struct ResponseMessageView: View {
    let response: URLResponseMessage

    var headers: [(key: String, value: String)] {
        let keys = response.headers.keys.sorted()
        return keys.map { key in (key, response.headers[key] ?? "N/A") }
    }

    @State var headersShown = false
    @State var bodyShown = false

    var statusColor: Color {
        guard let statusCode = response.statusCode else {
            return .secondary
        }

        switch statusCode {
        case 200..<400: return Color.green
        default: return Color.red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("HTTP")
                    Text("Response").bold()
                    if let statusCode = response.statusCode {
                        Text("\(statusCode)")
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .cornerRadius(2)
                            .background(statusColor.opacity(0.1))
                    }
                }

                Group {
                    if let urlString = response.url?.absoluteString {
                        Text(urlString)
                    } else {
                        Text("no url")
                    }
                }
            }
            .font(.system(.caption, design: .monospaced))
            .padding(.horizontal)

            Spacer(minLength: 16)

            Divider()

            VStack(spacing: 8) {
                ForEach(headers, id: \.key) { pair in
                    HStack {
                        Text("\(pair.key):")
                        Spacer()
                        Text(pair.value)
                    }
                    .font(.system(.caption, design: .monospaced))
                }
            }
            .padding()
            .collapsible(title: "Headers")

            if let body = response.body {
                Divider()
                ScrollView(.horizontal) {
                    Text(body)
                        .font(.system(.caption, design: .monospaced))
                        .fixedSize()
                        .padding()
                }
                .collapsible(title: "Body")
            }
        }
    }
}
