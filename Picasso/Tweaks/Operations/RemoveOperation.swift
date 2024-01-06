//
//  RemoveOperation.swift
//  Picasso
//
//  Created by sourcelocation on 07/08/2023.
//

import Foundation

public class RemoveOperation: Operation {
    @Published var path: String

    enum CodingKeys: String, CodingKey {
        case path = "originPath"
    }

    public init(path: String) {
        self.path = path
        super.init(type: .removing)
    }
    
    public override func perform(tweakURL: URL, preferences: [String : Any]) throws {
        guard FileManager.default.fileExists(atPath: path) else { return }
        let pathToFileC: UnsafeMutablePointer<CChar> = path.withCString { strdup($0) }
        funVnodeHide(pathToFileC)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode(String.self, forKey: .path)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try super.encode(to: encoder)
    }
}
