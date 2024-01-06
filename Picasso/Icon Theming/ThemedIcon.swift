//
//  ThemedIcon.swift
//  Picasso
//
//  Created by sourcelocation on 23/08/2023.
//

import Foundation

struct ThemedIcon: Codable {
    var appID: String
    var themeName: String
    var drm: Bool
    
//    var rawThemeIconURL: URL {
//        rawThemesDir.appendingPathComponent(themeName).appendingPathComponent(appID + ".png")
//    }
    
    func iconData() throws -> Data {
        let sourcedRepoTheme = drm
        let data = try Data(contentsOf: rawThemesDir.appendingPathComponent(themeName).appendingPathComponent(appID + ".png"))
        
        if !sourcedRepoTheme {
            return data
        } else {
//            return FunnyDataCoderForLocalStorage().decode(data: data)
            throw "Sourced Repo Themes are not supported in OpenPicasso."
        }
    }
//    func cachedThemeIconURL(fileName: String) -> URL {
//        processedThemesDir.appendingPathComponent(themeName).appendingPathComponent(appID + "----" + fileName)
//    }
}
