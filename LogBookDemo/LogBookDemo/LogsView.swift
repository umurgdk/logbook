import SwiftUI
import LogBook

public struct LogsView: View {
    @Environment(\.logBook) var logBook
    @State var logs: [Log] = []
    @Environment(\.presentationMode) var presentationMode

    @State var alertMessage: String = ""
    @State var isAlertShown = false

    @State var shareContinuation: () -> Void = { }
    @State var shareURL: URL?

    static let displayer = SwiftUILogDisplayer()
    var isSharePresented: Binding<Bool> {
        Binding {
            shareURL != nil
        } set: { newValue in
            shareURL = newValue ? shareURL : nil
        }
    }

    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(logs, id: \.createdAt) { log in
                    Self.displayer.display(log: log)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(16)
                }
            }
            .padding()
        }
        .background(Color.secondary.opacity(0.15).edgesIgnoringSafeArea(.all))
        .sheet(isPresented: isSharePresented) {
            ShareSheet(activityItems: [shareURL!]) {
                isSharePresented.wrappedValue = false
            }
        }
        .alert(isPresented: $isAlertShown, content: {
            Alert(title: Text(alertMessage), dismissButton: .default(Text("Okay")))
        })
        .onAppear {
            Task { logs = await logBook.logs() }
        }
        .navigationTitle("Logs")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.primary)
                        .opacity(0.5)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await shareLogs() }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    private func shareLogs() async {
        do {
            shareURL = try await logBook.withExportedLogFile()
        } catch {
            alertMessage = error.localizedDescription
            isAlertShown = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let completion: () -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in completion() }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}

public struct SwiftUILogDisplayer: LogDisplayer {
    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        return f
    }()

    public func display(log: Log) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(log.module).\(log.category)")
                    .foregroundColor(color(for: log.level))
                    .font(.caption)

                Spacer()

                Text("\(log.createdAt, formatter: Self.dateFormatter)")
                    .foregroundColor(.secondary)
                    .font(.caption2)
            }.padding()

            log.message.logView(hint: log.hint)
        }
    }

    private func pill(_ text: String, color: Color) -> some View {
        Text(text).foregroundColor(color)
    }

    private func title(for level: Log.Level) -> String {
        switch level {
        case .info: return "INFO"
        case .error: return "ERROR"
        }
    }

    private func color(for level: Log.Level) -> Color {
        switch level {
        case .info: return Color.secondary
        case .error: return Color.red
        }
    }
}

extension Data {
    @ViewBuilder
    func logView(hint: Log.Hint) -> some View {
        switch hint {
        case .text:
            Text(String(data: self, encoding: .utf8) ?? "N/A")
                .font(.system(.caption, design: .monospaced))
                .padding([.horizontal, .bottom])

        case .request:
            if let request = try? JSONDecoder().decode(URLRequestMessage.self, from: self) {
                RequestMessageView(request: request)
            } else {
                Text(String(data: self, encoding: .utf8) ?? "N/A")
                    .font(.system(.caption, design: .monospaced))
                    .padding([.horizontal, .bottom])
            }

        case .response:
            if let response = try? JSONDecoder().decode(URLResponseMessage.self, from: self) {
                ResponseMessageView(response: response)
            } else {
                Text(String(data: self, encoding: .utf8) ?? "N/A")
                    .font(.system(.caption, design: .monospaced))
                    .padding([.horizontal, .bottom])
            }
        }
    }
}

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

            Button {
                headersShown.toggle()
            } label: {
                HStack {
                    Text("Headers")
                    Spacer()
                    Image(systemName: headersShown ? "chevron.down" : "chevron.right")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            if headersShown {
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
            }

            Divider()

            if !request.body.isEmpty {
                Button {
                    bodyShown.toggle()
                } label: {
                    HStack {
                        Text("Body")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(bodyShown ? 90 : 0))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }

            if bodyShown {
                Divider()
                ScrollView(.horizontal) {
                    Text(request.body)
                        .font(.system(.caption, design: .monospaced))
                        .fixedSize()
                        .padding()
                }
            }
        }
    }
}

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

            Button {
                headersShown.toggle()
            } label: {
                HStack {
                    Text("Headers")
                    Spacer()
                    Image(systemName: headersShown ? "chevron.down" : "chevron.right")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            if headersShown {
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
            }

            Divider()

            if let _ = response.body {
                Button {
                    bodyShown.toggle()
                } label: {
                    HStack {
                        Text("Body")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(bodyShown ? 90 : 0))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }

            if bodyShown, let body = response.body {
                Divider()
                ScrollView(.horizontal) {
                    Text(body)
                        .font(.system(.caption, design: .monospaced))
                        .fixedSize()
                        .padding()
                }
            }
        }
    }
}
