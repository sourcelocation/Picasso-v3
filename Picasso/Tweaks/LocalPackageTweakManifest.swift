//
//  a.swift
//  Picasso
//
//  Created by sourcelocation on 10/08/2023.
//

import Combine
import SwiftUI

public class LocalPackageTweakManifest: Codable, ObservableObject {
    var spec: String = "1.0"

    @Published var operations: [Operation] = []

    enum CodingKeys: String, CodingKey {
        case spec = "spec"
        case operations = "operations"
    }

    enum OperationTypeKey: String, CodingKey {
        case type = "type"
    }

    enum OperationTypes: String, Decodable {
        case remove = "removing"
        case replace = "replacing"
        case replacingBundle = "replacing_bundle"
        case plistEditing = "plistEditing"
        case dynamicIsland = "dynamicIsland"
        case springboardColor = "springboardColor"
        case accentOperation = "accentOperation"
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        spec = try container.decode(String.self, forKey: .spec)
        spec = "1.0" // MARK: TODO

        var operationsArrayForType = try container.nestedUnkeyedContainer(forKey: .operations)
        var operations: [Operation] = []

        var operationsArray = operationsArrayForType
        while !operationsArrayForType.isAtEnd {
            let operation = try operationsArrayForType.nestedContainer(keyedBy: OperationTypeKey.self)
            let type = try operation.decode(OperationTypes.self, forKey: .type)
            switch type {
            case .remove:
                operations.append(try operationsArray.decode(RemoveOperation.self))
            case .replace:
                operations.append(try operationsArray.decode(ReplaceOperation.self))
            case .plistEditing:
                operations.append(try operationsArray.decode(PlistOperation.self))
            case .dynamicIsland:
                operations.append(try operationsArray.decode(DynamicIslandOperation.self))
            case .springboardColor:
                operations.append(try operationsArray.decode(ColorOperation.self))
            case .accentOperation:
                operations.append(try operationsArray.decode(AccentOperation.self))
            case .replacingBundle:
                operations.append(try operationsArray.decode(ReplaceBundleOperation.self))
            }
        }

        self.operations = operations
    }

    // encode "operations": each operation can be either ReplaceOperation or RemoveOperation. encode all other properties inside the operation itself

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(spec, forKey: .spec)

        var operationsArrayForType = container.nestedUnkeyedContainer(forKey: .operations)
        for operation in operations {
            try operationsArrayForType.encode(operation)
        }
    }


    public init(operations: [Operation]) {
        self.operations = operations
    }
}

