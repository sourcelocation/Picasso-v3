//
//  ReplaceOperation.swift
//  Picasso
//
//  Created by sourcelocation on 07/08/2023.
//

import Foundation
import URLBackport

public class ReplaceOperation: Operation {
    @Published var path: String
    @Published var replacementFileName: String
    @Published var replacementFileBundled: Bool

    enum CodingKeys: String, CodingKey {
        case replacementFileName = "replacementFileName"
        case replacementFileBundled = "replacementFileBundled"
        case path = "originPath"
    }

    public init(path: String, replacementFileName: String, replacementFileBundled: Bool) {
        self.path = path
        self.replacementFileName = replacementFileName
        self.replacementFileBundled = replacementFileBundled
        super.init(type: .replacing)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode(String.self, forKey: .path)
        replacementFileName = try container.decode(String.self, forKey: .replacementFileName)
        replacementFileBundled = try container.decode(Bool.self, forKey: .replacementFileBundled)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(replacementFileName, forKey: .replacementFileName)
        try container.encode(replacementFileBundled, forKey: .replacementFileBundled)
        try super.encode(to: encoder)
    }

    public override func perform(tweakURL: URL, preferences: [String: Any]) throws {
        let origin = URL.backport(filePath: path)
        let replacement = replacementFileBundled ? URL.backport(filePath: replacementFileName, relativeTo: tweakURL) : URL.backport(filePath: replacementFileName)
        try ExploitKit.shared.Overwrite(at: origin, withFileAtURL: replacement)
    }
}
