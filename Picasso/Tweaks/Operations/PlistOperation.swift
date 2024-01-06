//
//  PlistOperation.swift
//  Picasso
//
//  Created by sourcelocation on 07/08/2023.
//

import Foundation
import AnyCodable
import URLBackport

class PlistOperation: Operation {
    @Published var path: String
    var keyPath: String
    var value: AnyCodable
    var matchAllKeys: Bool

    init(path: String, keyPath: String, value: AnyCodable, matchAllKeys: Bool) {
        self.path = path
        self.keyPath = keyPath
        self.value = value
        self.matchAllKeys = matchAllKeys
        super.init(type: .plistEditing)
    }

    enum CodingKeys: String, CodingKey {
        case keyPath = "keyPath"
        case value = "value"
        case path = "path"
        case matchAllKeys = "matchAllKeys"
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(keyPath, forKey: .keyPath)
        try container.encode(value, forKey: .value)
        try container.encode(matchAllKeys, forKey: .matchAllKeys)
        try super.encode(to: encoder    )
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode(String.self, forKey: .path)
        keyPath = try container.decode(String.self, forKey: .keyPath)
        value = try container.decode(AnyCodable.self, forKey: .value)
        matchAllKeys = try container.decode(Bool.self, forKey: .matchAllKeys)
        try super.init(from: decoder)
    }

    /// Performs the operation on the given tweak URL, using PropertyListSerialization
    /// - Parameter tweakURL: The URL of the tweak
    override func perform(tweakURL: URL, preferences: [String: Any]) throws {
        let plistURL = URL.backport(filePath: path)
        let plistData = try Data(contentsOf: plistURL)
        var plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as! [String: Any]
        
        if matchAllKeys {
            plist.replaceValues(where: { $0 == keyPath }, with: value.value)
        }
//        plist.setValue(value.value, forKeyPath: keyPath.replacing("@@", with: "."))

        let serializedPlist = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try ExploitKit.shared.Overwrite(at: plistURL, with: serializedPlist)
    }
}


extension Dictionary {
    // 1    
    subscript<T>(_ type: T.Type, _ pathKeys: [Key]) -> T? {
        precondition(pathKeys.count > 0)

        if pathKeys.count == 1 {
            return self[pathKeys[0]] as? T
        }

    // Drill down to the innermost dictionary accessible through next-to-last key
        var dict: [Key: Value]? = self
        for currentKey in pathKeys.dropLast() {
            dict = dict?[currentKey] as? [Key: Value]
            if dict == nil {
                return nil
            }
        }

        return dict?[pathKeys.last!] as? T
    }

    // 2. Calls 1
    subscript<T>(_ type: T.Type, _ pathKeys: Key...) -> T? {
        return self[type, pathKeys]
    }
}

extension Dictionary where Key == String {
    // 3. Calls 1
    subscript<T>(_ type: T.Type, _ keyPath: String) -> T? {
        return self[type, keyPath.components(separatedBy: ".")]
    }
}
