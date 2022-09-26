import Foundation

public struct Log: Codable {
    public enum Level: String, Codable { case info, error }
    public enum Hint: String, Codable { case text, request, response }

    public let module: String
    public let category: String

    public let level: Level
    public let message: Data
    public let createdAt: Date
    public let hint: Hint

    init(level: Level, module: String, category: String, message: Data, hint: Hint = .text, createdAt: Date = Date()) {
        self.level = level
        self.message = message
        self.createdAt = createdAt
        self.module = module
        self.category = category
        self.hint = hint
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.module, forKey: .module)
        try container.encode(self.category, forKey: .category)
        try container.encode(self.level, forKey: .level)
        try container.encode(self.message, forKey: .message)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encode(self.hint, forKey: .hint)
    }
}
