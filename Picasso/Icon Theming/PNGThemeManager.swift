//
//  PNGThemeManager.swift
//  Picasso
//
//  Created by sourcelocation on 23/08/2023.
//

import Foundation

public class PNGThemeManager {
    static var shared = PNGThemeManager()
    var errors: [String] = []
    func performChanges(_ changes: [AppIconChange], progress: ((Double,String)) -> ()) throws {
        for (i,change) in changes.enumerated() {
            progress((Double(i) / Double(changes.count), change.app.bundleIdentifier))
            
            do {
                if let icon = change.icon {
                    let appURL = change.app.bundleURL
                    let catalogURL = appURL.appendingPathComponent("Assets.car")
                    
                    // apply
                    guard let icon = change.icon else { throw "Icon does not exist." }
                    
                    change.app.backUpPNGIcons()
                    try change.app.setPNGIcons(icon: icon)
                    
                    if change.app.isSystem {
                        try ExploitKit.shared.toggleCatalogCorruption(at: catalogURL, corrupt: true, usingExploit: true)
                    }
                } else {
                    // revert
                    
                    try change.app.restorePNGIcons()
                }
            } catch {
                errors.append("\(change.app.bundleIdentifier) (PNG)\n\(error.localizedDescription)\n")
            }
        }
        if !errors.isEmpty {
            throw errors.joined(separator: "\n")
        }
    }
}
