//
//  Theme.swift
//  Picasso
//
//  Created by sourcelocation on 23/08/2023.
//

import Foundation

class IconTheme: ObservableObject, Identifiable {
    var id = UUID()
    
    @Published var name: String
    @Published var iconCount: Int
    
    @Published var isSelected: Bool = false
    
    @Published var sourcedRepoTheme: Bool
    
    var url: URL { // Documents/ImportedThemes/Theme.theme
        return rawThemesDir.appendingPathComponent(name /*+ ".theme"*/)
    }
//    var cacheURL: URL { // Documents/ImportedThemes/Theme.theme
//        return processedThemesDir.appendingPathComponent(name /*+ ".theme"*/)
//    }
    
    init(name: String, iconCount: Int, sourcedRepoTheme: Bool) {
        self.name = name
        self.iconCount = iconCount
        self.sourcedRepoTheme = sourcedRepoTheme
    }
//    static func == (lhs: IconTheme, rhs: IconTheme) -> Bool {
//        return lhs.name == rhs.name
//    }
}
