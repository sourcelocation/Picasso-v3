//
//  ApplicationManager.swift
//  Picasso
//
//  Created by sourcelocation on 03/02/2023.
//

import UIKit
import AssetCatalogWrapper


class KFDApplicationManager {
    private static var fm = FileManager.default
    
    private static let systemApplicationsUrl = URL(fileURLWithPath: "/Applications", isDirectory: true)
    private static let userApplicationsUrl = URL(fileURLWithPath: "/var/containers/Bundle/Application", isDirectory: true)
    
    static func getApps(retainMountedOnly: [String]) throws -> [SBApp] {
        var dotAppDirs: [URL] = []
        
//        let sysmount = try KFD.mountFolderAtURL(systemApplicationsUrl)
//        let systemAppsDir = try fm.contentsOfDirectory(at: systemApplicationsUrl, includingPropertiesForKeys: nil)
//        dotAppDirs += systemAppsDir
        
//        try KFD.unmountFileAtURL(mountURL: sysmount.mountURL, orig_to_v_data: sysmount.orig_to_v_data)
        
        let usrmount = try KFD.mountFolderAtURL(userApplicationsUrl)
        let userAppsDir = try fm.contentsOfDirectory(at: usrmount.mountURL, includingPropertiesForKeys: nil)
        
        for userAppFolder in userAppsDir {
            let appFolderMount = try KFD.mountFolderAtURL(userAppFolder)
            let userAppFolderContents = try fm.contentsOfDirectory(at: appFolderMount.mountURL, includingPropertiesForKeys: nil)
            if let dotApp = userAppFolderContents.first(where: { $0.absoluteString.hasSuffix(".app/") }) {
                dotAppDirs.append(userApplicationsUrl.appendingPathComponent(userAppFolder.lastPathComponent).appendingPathComponent(dotApp.lastPathComponent))
            }
            try KFD.unmountFileAtURL(mountURL: appFolderMount.mountURL, orig_to_v_data: appFolderMount.orig_to_v_data)
        }
        
        var apps: [SBApp] = []
        
        for bundleUrl in dotAppDirs {
            let bundleUrlMount = try KFD.mountFolderAtURL(bundleUrl)
            
            let infoPlistUrl = bundleUrlMount.mountURL.appendingPathComponent("Info.plist")
            
            guard let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as? [String:AnyObject] else { continue }
            guard let CFBundleIdentifier = infoPlist["CFBundleIdentifier"] as? String else { throw "No bundle ID for \(bundleUrl.absoluteString)" }
            var app = SBApp(bundleIdentifier: CFBundleIdentifier, name: "Unknown", version: infoPlist["CFBundleShortVersionString"] as? String ?? "1", bundleURL: bundleUrl, pngIconPaths: [], hiddenFromSpringboard: false, mountedPoint: (url: bundleUrlMount.mountURL, vnode: bundleUrlMount.orig_to_v_data))
            
            if infoPlist.keys.contains("CFBundleDisplayName") {
                guard let CFBundleDisplayName = infoPlist["CFBundleDisplayName"] as? String else { throw "Error reading display name for \(bundleUrl.absoluteString)" }
                app.name = CFBundleDisplayName
            } else if infoPlist.keys.contains("CFBundleName") {
                guard let CFBundleName = infoPlist["CFBundleName"] as? String else { throw "Error reading name for \(bundleUrl.absoluteString)" }
                app.name = CFBundleName
            }
            
            // obtaining png icons inside bundle. defined in info.plist
            if app.bundleIdentifier == "com.apple.mobiletimer" {
                // use correct paths for clock, because it has arrows
                app.pngIconPaths += ["circle_borderless@2x~iphone.png"]
            }
            if let CFBundleIcons = infoPlist["CFBundleIcons"] {
                if let CFBundlePrimaryIcon = CFBundleIcons["CFBundlePrimaryIcon"] as? [String : AnyObject] {
                    if let CFBundleIconFiles = CFBundlePrimaryIcon["CFBundleIconFiles"] as? [String] {
                        app.pngIconPaths += CFBundleIconFiles.map { $0 + "@2x.png"}
                    }
                    if let CFBundleIconName = CFBundlePrimaryIcon["CFBundleIconName"] as? String {
                        app.plistIconName = CFBundleIconName
                    }
                }
            }
            if infoPlist.keys.contains("CFBundleIconFile") {
                // happens in the case of pseudo-installed apps
                if let CFBundleIconFile = infoPlist["CFBundleIconFile"] as? String {
                    app.pngIconPaths.append(CFBundleIconFile + ".png")
                }
            }
            if infoPlist.keys.contains("CFBundleIconFiles") {
                // only seen this happen in the case of Wallet
                if let CFBundleIconFiles = infoPlist["CFBundleIconFiles"] as? [String], !CFBundleIconFiles.isEmpty {
                    app.pngIconPaths += CFBundleIconFiles.map { $0.replacingOccurrences(of: ".png", with: "") + ".png" }
                }
            }
            
            // check if app is hidden
            if let SBAppTags = infoPlist["SBAppTags"] as? [String], !SBAppTags.isEmpty {
                if SBAppTags.contains("hidden") {
                    app.hiddenFromSpringboard = true
                }
            }
            
            apps.append(app)
            if !retainMountedOnly.contains(app.bundleIdentifier) {
                try KFD.unmountFileAtURL(mountURL: bundleUrlMount.mountURL, orig_to_v_data: bundleUrlMount.orig_to_v_data)
            }
        }
        
        
        try KFD.unmountFileAtURL(mountURL: usrmount.mountURL, orig_to_v_data: usrmount.orig_to_v_data)
        
        return apps
    }
}
