//
//  WebclipThemeManager.swift
//  Picasso
//
//  Created by sourcelocation on 26.10.2023.
//
//
import UIKit

class WebClipThemeManager {
    static var shared = WebClipThemeManager()
    var fm = FileManager.default
    
    
    func performChanges(_ changes: [AppIconChange], progress: ((Double,String)) -> ()) throws {
        var errors: [String] = []
        
        for (i,change) in changes.enumerated() {
            progress((Double(i) / Double(changes.count), change.app.bundleIdentifier))
            do {
                let appID = change.app.bundleIdentifier
                
                if let icon = change.icon {
                    print("Adding webclip for icon")
                    try? removeWebClip(appID: change.app.bundleIdentifier)
                    try addWebClip(appID: appID, displayName: change.app.name, icon: icon)
                } else {
                    try? removeWebClip(appID: change.app.bundleIdentifier)
                }
            } catch {
                errors.append("\(change.app.bundleIdentifier) (WEBCLIP)\n\(error.localizedDescription)\n")
            }
        }
        if !errors.isEmpty {
            throw errors.joined(separator: "\n")
        }
    }
    
    func removeWebclips() throws {
        for url in try fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile/Library/WebClips/"), includingPropertiesForKeys: nil) {
            guard url.lastPathComponent.contains(".Picasso-") else { continue }
            try fm.removeItem(at: url)
        }
    }
    
    
    private func webClipURL(appID: String) -> URL {
        URL(fileURLWithPath: "/var/mobile/Library/WebClips/.Picasso-\(appID).webclip")
    }
    func addWebClip(appID: String, displayName: String, icon: ThemedIcon) throws {
        let webClipURL = webClipURL(appID: appID)
        try fm.createDirectory(at: webClipURL, withIntermediateDirectories: true)
        
        let data = try Data(contentsOf: Bundle.main.url(forResource: "WebClipTemplate", withExtension: "plist")!)
        guard var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:Any] else { throw "Template plist not found" }
        
        plist["ApplicationBundleIdentifier"] = appID
        plist["Title"]                       = displayName
        
        let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try? fm.removeItem(at: webClipURL.appendingPathComponent("icon.png"))
        
        let iconData = try icon.iconData()
        let iconURL = webClipURL.appendingPathComponent("icon.png")
        try iconData.write(to: iconURL)
        try plistData.write(to: webClipURL.appendingPathComponent("Info.plist"))
        print("Written webclip")
    }
    func removeWebClip(appID: String) throws {
        print("Removing webclip at \(webClipURL(appID: appID))")
        try fm.removeItem(at: webClipURL(appID: appID))
        print("Success")
    }
}
