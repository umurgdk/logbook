import SwiftUI
import LogBook

struct RequestMessageView: View {
    let request: URLRequestMessage

    var headers: [(key: String, value: String)] {
        let keys = request.headers.keys.sorted()
        return keys.map { key in (key, request.headers[key] ?? "N/A") }
    }

    @State var headersShown = false
    @State var bodyShown = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("HTTP \(request.httpMethod) ") + Text("Request").bold()

                Group {
                    if let urlString = request.url?.absoluteString {
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

            if !request.body.isEmpty {
                Divider()
                ScrollView(.horizontal) {
                    Text(request.body)
                        .font(.system(.caption, design: .monospaced))
                        .fixedSize()
                        .padding()
                }.collapsible(title: "Body")
            }
        }
    }
}
