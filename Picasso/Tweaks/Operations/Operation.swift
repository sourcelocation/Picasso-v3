//
//  Operation.swift
//  Picasso
//
//  Created by sourcelocation on 07/08/2023.
//

import Foundation
import AnyCodable

public enum OperationType: String, Codable, Equatable {
    case replacing = "replacing"
    case removing = "removing"
    case plistEditing = "plistEditing"
    case dynamicIsland = "dynamicIsland"
    case springboardColor = "springboardColor"
    case accentOperation = "accentOperation"
    case replacing_bundle = "replacing_bundle"
}

public class Operation: ObservableObject, Codable, Identifiable {
    public var id = UUID()
    @Published var type: OperationType
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
    }

    public init(type: OperationType) {
        self.type = type
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(OperationType.self, forKey: .type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
    }

    public func perform(tweakURL: URL, preferences: [String: Any]) throws {
        fatalError("Operation.perform() not implemented")
    }
    
    public func revert(tweakURL: URL) throws {
        print("Nothing to revert")
    }
}

