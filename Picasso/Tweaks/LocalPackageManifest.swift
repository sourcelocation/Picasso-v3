//
//  a.swift
//  Picasso
//
//  Created by sourcelocation on 10/08/2023.
//

import Combine
import SwiftUI

public class LocalPackageManifest: Codable, ObservableObject {
    var bundleID: String
    var name: String
    var author: String
    var version: String
    var iconURL: URL?
    
    convenience init(createDefaultWithName name: String) {
        self.init(bundleID: "com.example.\(name.lowercased().replacingOccurrences(of: " ", with: ""))", name: name, author: "Unknown", version: "1.0", iconURL: nil)
    }

    init(bundleID: String, name: String, author: String, version: String, iconURL: URL?) {
        self.bundleID = bundleID
        self.name = name
        self.author = author
        self.version = version
        self.iconURL = iconURL
    }
}


