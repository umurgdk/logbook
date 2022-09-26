import Foundation

extension URLRequest: LogMessageProvider {
    public var logMessage: some LogMessage {
        URLRequestMessage(from: self)
    }
}

public struct URLRequestMessage: LogMessage {
    public var url: URL?
    public var httpMethod: String = "GET"
    public var headers: [String: String] = [:]
    public var body: String = ""

    public var hint: Log.Hint { .request }

    public init(url: URL, httpMethod: String = "GET", headers: [String : String] = [:], body: String = "") {
        self.url = url
        self.httpMethod = httpMethod
        self.headers = headers
        self.body = body
    }

    public init(from request: URLRequest) {
        self.url = request.url
        self.httpMethod = request.httpMethod ?? "N/A"

        for header in request.allHTTPHeaderFields ?? [:] {
            headers[header.key] = header.value
        }

        if
            let body = request.httpBody,
            let bodyJSON = try? JSONSerialization.jsonObject(with: body),
            let data = try? JSONSerialization.data(withJSONObject: bodyJSON, options: .prettyPrinted),
            let dataString = String(data: data, encoding: .utf8)
        {
            self.body = dataString
        } else {
            let bodyString = request.httpBody.flatMap {
                String(data: $0, encoding: .utf8)
            }

            if let bodyString = bodyString {
                self.body = bodyString
            } else if request.httpBody?.isEmpty ?? false {
                self.body = "Empty"
            } else if let body = request.httpBody {
                self.body = "Binary data (\(body.count) bytes)"
            }
        }
    }
}
