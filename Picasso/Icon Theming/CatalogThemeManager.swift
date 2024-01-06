//
//  CatalogThemeManager.swift
//  Picasso
//
//  Created by sourcelocation on 28/11/2023.
//

import Foundation
import AssetCatalogWrapper

public class CatalogThemeManager {
    static var shared = CatalogThemeManager()
    
    func performChanges(_ changes: [AppIconChange], progress: ((Double,String)) -> ()) throws {
        var errors: [String] = []
        
        for (i,change) in changes.enumerated() {
            progress((Double(i) / Double(changes.count), change.app.bundleIdentifier))
            print("Applying change for app \(change.app)")
            do {
                let appURL = change.app.bundleURL
                let catalogURL = appURL.appendingPathComponent("Assets.car")
                let backupURL = change.app.bundleURL.appendingPathComponent("PicassoBackup-\(change.app.version).car")
                
                if let icon = change.icon {
                    // MARK: Apply icon
                    if !FileManager.default.fileExists(atPath: backupURL.path) {
                        try TrollStoreRootHelper.copy(from: catalogURL, to: backupURL)
                        print("created backup from \(catalogURL) to \(backupURL)")
                    }
                    
                    let imgData = try icon.iconData()
                    guard let image = UIImage(data: imgData) else { throw "not a valid image" }
                    guard let cgImage = image.cgImage else { throw "unable to get cgimage" }
                    
                    try modifyIconInCatalog(url: catalogURL, to: cgImage, isSystem: change.app.isSystem)
                } else {
                    // MARK: Revert icon
                    guard FileManager.default.fileExists(atPath: catalogURL.path) else { throw "Catalog doesn't exist? Skipping." }
                    guard FileManager.default.fileExists(atPath: backupURL.path) else { continue }
                    if change.app.isSystem && ExploitKit.shared.hasSystemOverwrite {
                        try ExploitKit.shared.Overwrite(at: catalogURL, withFileAtURL: backupURL)
                    } else {
                        try TrollStoreRootHelper.removeItem(at: catalogURL)
                        try TrollStoreRootHelper.move(from: backupURL, to: catalogURL)
                    }
                }
            } catch {
                errors.append("\(change.app.bundleIdentifier) (CATALOG)\n\(error.localizedDescription)\n")
            }
        }
        if !errors.isEmpty {
            throw errors.joined(separator: "\n")
        }
    }
    
    func modifyIconInCatalog(url: URL, to icon: CGImage, isSystem: Bool) throws {
        print("Modifying icon in catalog...")
        try? FileManager.default.createDirectory(at: URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-Picasso/"), withIntermediateDirectories: true, attributes: [:])
        let tempAssetsURL = URL(fileURLWithPath: "/var/mobile/.DO-NOT-DELETE-Picasso/temp-\(UUID()).car")
        
        
        try TrollStoreRootHelper.move(from: url, to: tempAssetsURL)
        defer {
            if isSystem && ExploitKit.shared.hasSystemOverwrite {
                try? ExploitKit.shared.Overwrite(at: url, withFileAtURL: tempAssetsURL)
            } else {
                try? TrollStoreRootHelper.move(from: tempAssetsURL, to: url)
            }
        }

        try TrollStoreRootHelper.setPermission(url: tempAssetsURL)
        let (catalog, renditionsRoot) = try AssetCatalogWrapper.shared.renditions(forCarArchive: tempAssetsURL)
        for rendition in renditionsRoot {
            let type = rendition.type
            guard type == .icon else { continue }
            let renditions = rendition.renditions
            for rend in renditions {
                do {
                    try catalog.editItem(rend, fileURL: tempAssetsURL, to: .image(icon))
                }
            }
        }
    }
    
    func uncorruptCatalogs() throws {
        let systemApps = try ApplicationManager.getApps().filter({ $0.isSystem })
        for app in systemApps {
            let catalogURL = app.bundleURL.appendingPathComponent("Assets.car")
            print("trying to uncorrupt \(catalogURL.path) with kfd")
            try? ExploitKit.shared.toggleCatalogCorruption(at: catalogURL, corrupt: false, usingExploit: true)
        }
    }
}
