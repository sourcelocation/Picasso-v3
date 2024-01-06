//
//  RepoPackage.swift
//  Picasso
//
//  Created by sourcelocation on 04/08/2023.
//

import Foundation

public class RepoPackage: Codable {
    var bundleID: String
    var name: String
    var description: String?
    var author: String
    var version: String
    
    var icon: String
    var iconURL: URL!
    
    var path: String
    var downloadURL: URL!

    var minPicassoVersion: String?
    var minPicassoBuild: String?
    

    enum CodingKeys: String, CodingKey {
        case bundleID = "bundleid"
        case name = "name"
        case description = "description"
        case author = "author"
        case version = "version"
        case icon = "icon"
        case path = "path"
        case iconURL = "iconURL"
        case minPicassoVersion = "minPicassoVersion"
        case minPicassoBuild = "minPicassoBuild"
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bundleID = try container.decode(String.self, forKey: .bundleID)
        name = try container.decode(String.self, forKey: .name)
        description = try? container.decode(String.self, forKey: .description)
        author = try container.decode(String.self, forKey: .author)
        version = try container.decode(String.self, forKey: .version)
        icon = try container.decode(String.self, forKey: .icon)
        path = try container.decode(String.self, forKey: .path)
        iconURL = try? container.decode(URL.self, forKey: .iconURL)
        minPicassoVersion = try? container.decode(String.self, forKey: .minPicassoVersion)
        minPicassoBuild = try? container.decode(String.self, forKey: .minPicassoBuild)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bundleID, forKey: .bundleID)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(author, forKey: .author)
        try container.encode(version, forKey: .version)
        try container.encode(icon, forKey: .icon)
        try container.encode(path, forKey: .path)
        try container.encode(iconURL, forKey: .iconURL)
        try container.encode(minPicassoVersion, forKey: .minPicassoVersion)
        try container.encode(minPicassoBuild, forKey: .minPicassoBuild)
    }

    public func prepareURLs(repoURL: URL) {
        iconURL = repoURL.appendingPathComponent(icon)
        downloadURL = repoURL.appendingPathComponent(path)
    }
}
