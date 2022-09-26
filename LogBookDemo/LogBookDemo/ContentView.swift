import SwiftUI
import LogBook
import LogBookUI

struct ContentView: View {
    @Environment(\.logger) var logger
    @State var showingLogs = false
    @State var logMessage = ""
    @State var level = Log.Level.info

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HStack {
                    TextField("Message...", text: $logMessage)
                        .textFieldStyle(.roundedBorder)

                    Picker("Log level", selection: $level) {
                        Text("Info").tag(Log.Level.info)
                        Text("Error").tag(Log.Level.error)
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
                .padding()
                .background(Color.secondary.opacity(0.1).edgesIgnoringSafeArea(.all))
                .overlay(Divider(), alignment: .bottom)

                Button("Create Log") {
                    switch level {
                    case .info:
                        logger.info(logMessage)
                    case .error:
                        logger.error(logMessage)
                    }
                }.padding()

                Button("Create URLRequest Log") {
                    createURLRequestLog()
                }.padding()

                Button("Create URLResponse Log") {
                    createURLResponseLog()
                }.padding()

                Button("Create Failure URLResponse Log") {
                    createFailureURLResponseLog()
                }.padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            Button("Show Logs") {
                showingLogs = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.secondary.opacity(0.1).edgesIgnoringSafeArea(.all))
        }
        .sheet(isPresented: $showingLogs) {
            NavigationView {
                LogsView()
            }
        }
    }

    private func createURLRequestLog() {
        let url = URL(string: "https://localhost/api/resource")!
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer Token", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("en-US", forHTTPHeaderField: "Accept-Language")

        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: [
            "field": "value",
            "some": [
                "another": "value nested"
            ]
        ])

        logger.info(urlRequest)
    }

    private func createURLResponseLog() {
        let url = URL(string: "https://localhost/api/resource")!
        let bodyData = try? JSONSerialization.data(withJSONObject: [
            "field": "value",
            "some": [
                "another": "value nested"
            ]
        ], options: .prettyPrinted)

        let body = String(data: bodyData ?? Data(), encoding: .utf8) ?? "N/A"

        let message = URLResponseMessage(
            url: url,
            statusCode: 200,
            body: body,
            headers: [
                "Content-Type": "application/json"
            ])

        logger.info(message)
    }

    private func createFailureURLResponseLog() {
        let url = URL(string: "https://localhost/api/resource")!
        let bodyData = try? JSONSerialization.data(withJSONObject: [
            "field": "value",
            "errors": [
                ["code": 1280, "message": "request doesnt makes sense!"]
            ]
        ], options: .prettyPrinted)

        let body = String(data: bodyData ?? Data(), encoding: .utf8) ?? "N/A"

        let message = URLResponseMessage(
            url: url,
            statusCode: 404,
            body: body,
            headers: [
                "Content-Type": "application/json"
            ])

        logger.info(message)
    }
}

struct ContentView_Previews: PreviewProvider {
    static let logBook = LogBook(persistance: InMemoryPersistance())
    static var previews: some View {
        ContentView()
            .environment(\.logger, logBook.makeLogger("Root", in: "DemoApp"))
    }
}
