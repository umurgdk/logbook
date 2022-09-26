import Foundation

public struct URLResponseMessage: LogMessage {
    public let url: URL?
    public let statusCode: Int?
    public let body: String?
    public let headers: [String: String]

    public var hint: Log.Hint { .response }

    public init(_ response: URLResponse, data: Data?) {
        url = response.url
        statusCode = (response as? HTTPURLResponse)?.statusCode
        headers = (response as? HTTPURLResponse)?.allHeaderFields as? [String: String] ?? [:]

        if
            let body = data,
            let bodyJSON = try? JSONSerialization.jsonObject(with: body),
            let data = try? JSONSerialization.data(withJSONObject: bodyJSON, options: .prettyPrinted),
            let dataString = String(data: data, encoding: .utf8)
        {
            self.body = dataString
        } else {
            let bodyString = data.flatMap {
                String(data: $0, encoding: .utf8)
            }

            if let bodyString = bodyString {
                self.body = bodyString
            } else if data?.isEmpty ?? false {
                self.body = "Empty"
            } else if let body = data {
                self.body = "Binary data (\(body.count) bytes)"
            } else {
                self.body = nil
            }
        }
    }


    public init(url: URL? = nil, statusCode: Int? = nil, body: String? = nil, headers: [String : String]) {
        self.url = url
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
    }
}
