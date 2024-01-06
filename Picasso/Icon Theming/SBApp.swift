//
//  SBIcon.swift
//  Picasso
//
//  Created by sourcelocation on 28/11/2023.
//

import Foundation
import AssetCatalogWrapper

struct SBApp {
    private let fm = FileManager.default
    
    var bundleIdentifier: String
    var name: String
    var version: String
    var bundleURL: URL
    
    var plistIconName: String?
    var pngIconPaths: [String]
    var hiddenFromSpringboard: Bool
    
    var mountedPoint: (url: URL, vnode: UInt64)
    
    var isSystem: Bool {
        bundleURL.pathComponents.count >= 2 && bundleURL.pathComponents[1] == "Applications"
    }
    
    func catalogIconName() -> String? {
        if bundleIdentifier == "com.apple.mobiletimer" {
            return "ClockIconBackgroundSquare"
        } else {
            return plistIconName
        }
    }
    func assetsCatalogURL() -> URL {
        if bundleIdentifier == "com.apple.mobiletimer" {
            return URL(fileURLWithPath: "/System/Library/PrivateFrameworks/SpringBoardHome.framework/Assets.car")
        } else {
            return bundleURL.appendingPathComponent("Assets.car")
        }
    }
    
    
    struct BackedUpPNG {
        var bundleIdentifier: String
        var iconName: String
        var data: Data
    }
    /// bundle id, icon name in .app, img data
    private func backedUpPNGs() -> [BackedUpPNG] {
        var res: [BackedUpPNG] = []
        for url in (try? fm.contentsOfDirectory(at: originalIconsDir, includingPropertiesForKeys: nil)) ?? [] {
            let items = url.lastPathComponent.components(separatedBy: "----")
            guard let data = try? Data(contentsOf: url) else { continue }
            res.append(.init(bundleIdentifier: items[0], iconName: items[1], data: data))
        }
        return res
    }
    
    func backUpPNGIcons() {
        for pngIconPath in pngIconPaths {
            let oldURL = originalIconsDir.appendingPathComponent(bundleIdentifier + "----" + pngIconPath)
            
            if fm.fileExists(atPath: oldURL.path) {
                try? fm.moveItem(at: oldURL, to: backupIconURL(fileName: pngIconPath))
            } else {
                let url = bundleURL.appendingPathComponent(pngIconPath)
                try? fm.copyItem(at: url, to: backupIconURL(fileName: pngIconPath))
            }
        }
    }
    
    func backupIconURL(fileName: String) -> URL {
        originalIconsDir.appendingPathComponent(bundleIdentifier + "----" + version + "----"  + fileName)
    }
    
    func backedUpIconURL(fileName: String) -> URL? {
        let newURL = backupIconURL(fileName: fileName)
        let oldURL = originalIconsDir.appendingPathComponent(bundleIdentifier + "----" + fileName)
        
        if fm.fileExists(atPath: newURL.path) {
            return newURL
        } else if fm.fileExists(atPath: newURL.path) {
            return oldURL
        } else {
            return nil
        }
    }
    
    func restorePNGIcons() throws {
        for iconName in pngIconPaths {
            try autoreleasepool {
                let iconURL = bundleURL.appendingPathComponent(iconName)
                guard let urlOfOriginal = backedUpIconURL(fileName: iconName) else { return }
                if let data = try? Data(contentsOf: urlOfOriginal) {
                    if ExploitKit.shared.hasSystemOverwrite && self.isSystem {
                        try? ExploitKit.shared.Overwrite(at: iconURL, with: data)
                    } else {
                        try data.write(to: iconURL)
                    }
                }
            }
        }
    }
    
    func setPNGIcons(icon: ThemedIcon) throws {
        for iconName in pngIconPaths {
            try autoreleasepool {
                let iconURL = bundleURL.appendingPathComponent(iconName)
                
                var cachedIcon: Data? = nil
                
                if cachedIcon == nil {
                    let imgData = try icon.iconData()
                    
                    if !self.isSystem {
                        cachedIcon = imgData
                    } else {
                        guard let themeIcon = UIImage(data: imgData) else { throw "Could not read image data from icon" }
                        
                        guard let origImageData = try? Data(contentsOf: iconURL) else { print("icon not found at the specified path. \(iconName)"); return } // happens for calendar for some reason
                        let origImageSize = origImageData.count
                        
                        guard let origImage = UIImage(data: origImageData) else { throw "Could not read image data from original icon at path" }
                        let width = origImage.size.width / 2
                        
                        var processedImage: Data?
                        
                        var resScale: CGFloat = 1
                        while resScale > 0.01 {
                            let sizeWithAppliedScale = width * resScale
                            let size = CGSize(width: sizeWithAppliedScale, height: sizeWithAppliedScale)
                            
                            processedImage = try? UIGraphicsImageRenderer(size: size).image { _ in themeIcon.draw(in: CGRect(origin: .zero, size: size)) }.resizeToApprox(allowedSizeInBytes: origImageSize)
                            if processedImage != nil { break }
                            
                            resScale *= 0.75
                        }
                        
                        guard let processedImage = processedImage else {
                            print("could not compress image low enough to fit inside original \(origImageData.count) bytes. path to orig \(iconURL.path), path to theme icon \(iconURL.path)")
                            return
                        }
                        cachedIcon = processedImage
                    }
                }
                if ExploitKit.shared.hasSystemOverwrite && self.isSystem {
                    try? ExploitKit.shared.Overwrite(at: iconURL, with: cachedIcon!)
                } else {
                    guard let data = String(data: cachedIcon!, encoding: .ascii) else { throw "couldn't gen data from cachedicon" }
                    try TrollStoreRootHelper.write(data, to: iconURL)
                }
            }
        }
    }
}
