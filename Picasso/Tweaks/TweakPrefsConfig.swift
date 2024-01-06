import Foundation
import AnyCodable

public class TweakPrefsConfig: ObservableObject, Identifiable, Codable {
    public var id = UUID()
    @Published var preferences: [TweakPreference]
    
    enum CodingKeys: String, CodingKey {
        case preferences = "preferences"
    }
    
    public init(preferences: [TweakPreference]) {
        self.preferences = preferences
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        preferences = try container.decode([TweakPreference].self, forKey: .preferences)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(preferences, forKey: .preferences)
    }
}


public class TweakPreference: ObservableObject, Identifiable, Codable {
    public var id = UUID()
    @Published var key: String
    @Published var valueType: String
    @Published var title: String
    @Published var description: String?
    
    enum CodingKeys: String, CodingKey {
        case key = "key"
        case valueType = "valueType"
        case title = "title"
        case description = "description"
    }

    public init(key: String, valueType: String, title: String, description: String?) {
        self.key = key
        self.valueType = valueType
        self.title = title
        self.description = description
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        valueType = try container.decode(String.self, forKey: .valueType)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String?.self, forKey: .description)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(valueType, forKey: .valueType)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
    }
}
