//
//  ThemeManager.swift
//  TrollTools
//
//  Created by exerhythm on 19.10.2022.
//

import UIKit
import ZIPFoundation
import CryptoKit


var rawThemesDir: URL = {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("InstalledThemes/")
}()
var originalIconsDir: URL = {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("OriginalIconsBackup/")
}()

var themingInProgress = false

public class ThemeManager: ObservableObject {
    
    static public let shared = ThemeManager()
    let fm = FileManager.default
    
    @Published var themes: [IconTheme] = []
    
    // MARK: - Utils
    private func iconFileEnding(iconFilename: String) -> String {
        if iconFilename.contains("-large.png") {
            return "-large"
        } else if iconFilename.contains("@2x.png") {
            return"@2x"
        } else if iconFilename.contains("@3x.png") {
            return "@3x"
        } else {
            return ""
        }
    }
    
    public func apply(progress: @escaping (String, Double) -> ()) throws {
        print("Applying")
        let changes: [AppIconChange] = try neededChanges()
        
        var errors: [String] = []
        
        var pngIconThemingOn = UserDefaults.standard.bool(forKey: "pngIconTheming")
        
        if ExploitKit.shared.hasSystemOverwrite && pngIconThemingOn {
            do {
                print("PNGs...")
                UserDefaults.standard.set(true, forKey: "needsCatalogFixup")
                try PNGThemeManager.shared.performChanges(changes) { (d,s) in
                    print(d,s)
                    progress("Applying using PNG method:\n\(s)", d * 100 / 3 + 0.0)
                }
            } catch {
                errors.append(error.localizedDescription)
            }
        }
        
        do {
            print("Catalogs...")
            try CatalogThemeManager.shared.performChanges(changes.filter { !$0.app.isSystem }) { (d,s) in
                print(d,s)
                progress("Applying using Assets.car method:\n\(s)", d * 100 / 3 + 33.3)
            }
        } catch {
            errors.append(error.localizedDescription)
        }
        
        if !(ExploitKit.shared.hasSystemOverwrite && pngIconThemingOn) { // we dont need webclips if we can write to system apps
            do {
                print("Webclips...")
                try WebClipThemeManager.shared.performChanges(changes.filter { $0.app.isSystem }) { (d,s) in
                    print(d,s)
                    progress("Applying using WebClips method:\n\(s)", d * 100 / 3 + 66.7)
                }
            } catch {
                errors.append(error.localizedDescription)
            }
        } else {
            do {
                print("Deleting Webclips...")
                try WebClipThemeManager.shared.removeWebclips()
            } catch {
                errors.append(error.localizedDescription)
            }
        }
        
        if !errors.isEmpty {
            throw errors.joined(separator: "\n\n\n")
        }
    }
    
    private func appIDFromIcon(url: URL) -> String {
        return url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: iconFileEnding(iconFilename: url.lastPathComponent), with: "")
    }
    private func iconData(appID: String, in theme: IconTheme) throws -> Data {
        let sourcedRepoTheme = theme.sourcedRepoTheme
        let data = try Data(contentsOf: theme.url.appendingPathComponent(appID + ".png"))
        
        if !sourcedRepoTheme {
            return data
        } else {
//            return FunnyDataCoderForLocalStorage().decode(data: data)
            throw "Sourced Repo Themes are not supported in OpenPicasso."
        }
    }
    
    private func getThemes() -> [IconTheme] {
        return ((try? FileManager.default.contentsOfDirectory(at: rawThemesDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)) ?? []).map { url in
            let theme = IconTheme(name: url.lastPathComponent, iconCount: 0, sourcedRepoTheme: FileManager.default.fileExists(atPath: url.appendingPathComponent(".sourced-repo-theme").path))
            theme.iconCount = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).count) ?? 0
            return theme
        }
    }
    
    public func importTheme(iconBundle: URL) throws {
        iconBundle.startAccessingSecurityScopedResource()
        let themeName = iconBundle.deletingPathExtension().lastPathComponent
        try? fm.createDirectory(at: rawThemesDir, withIntermediateDirectories: true)
        let themeURL = rawThemesDir.appendingPathComponent(themeName)
        
        try fm.createDirectory(at: themeURL, withIntermediateDirectories: true)
        
        for icon in (try? fm.contentsOfDirectory(at: iconBundle, includingPropertiesForKeys: nil)) ?? [] {
            guard !icon.lastPathComponent.contains(".DS_Store") else { continue }
            try? fm.copyItem(at: icon, to: themeURL.appendingPathComponent(appIDFromIcon(url: icon) + ".png"))
        }
        updateThemes()
        iconBundle.stopAccessingSecurityScopedResource()
    }
    
    func downloadSourcedRepoTheme(repoTheme: SourcedRepoFetcher.RepoTheme) async throws {
        throw "Sourced Repo Themes are not supported in OpenPicasso."
//        let downloadURL = rawThemesDir.appendingPathComponent(repoTheme.name)
//        try? FileManager.default.createDirectory(at: downloadURL, withIntermediateDirectories: true)
        
//        let themeData = try await SourcedRepoFetcher.shared.fetchTheme(repoTheme: repoTheme)
//        
//        guard let archive = Archive(data: themeData, accessMode: .update),
//              let iconBundlesEntry = archive.makeIterator().next() else {
//            throw "Unable to get IconBundles from the downloaded theme. This is an error on our end, please report it to us using Discord / Twitter."
//        }
//        
////        try themeData.write(to: URL(fileURLWithPath: "/Users/sourcelocation/Downloads/aaa.zip"))
//        
//        for entry in archive {
//            if entry.type == .file, entry.path.contains(".png"), !entry.path.contains("__MACOSX") {
//                print(entry.path)
//                guard let fileName = entry.path.components(separatedBy: "/").last else { continue }
//                var iconData = Data()
//                _ = try archive.extract(entry, skipCRC32: true, progress: nil) { data in
//                    iconData.append(data)
//                }
//                let appID = getAppIDFromIconFile(downloadURL.appendingPathComponent(fileName))
//                try FunnyDataCoderForLocalStorage().encode(data: iconData).write(to: downloadURL.appendingPathComponent("\(appID).png"))
//            }
//        }
//        print(downloadURL)
//        FileManager.default.createFile(atPath: downloadURL.appendingPathComponent(".sourced-repo-theme").path, contents: "https://server1.sourceloc.net".data(using: .utf8))
    }
        
    func deleteTheme(theme: IconTheme) throws {
        try fm.removeItem(at: theme.url)
        updateThemes()
    }
    
    public func updateThemes() {
        themes = getThemes()
    }
    
    private func getAppIDFromIconFile(_ url: URL) -> String {
        return url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: iconFileEnding(iconFilename: url.lastPathComponent), with: "")
    }
    
    // MARK: Changes

    ///
    private func themedIcons() throws -> [String: ThemedIcon] {
        var icons: [String: ThemedIcon] = [:]
        
        for theme in themes {
            guard theme.isSelected else { continue }
            let iconImages = try FileManager.default.contentsOfDirectory(at: theme.url, includingPropertiesForKeys: nil)
            for iconImage in iconImages {
                let appID = getAppIDFromIconFile(iconImage)
                
                icons[appID] = .init(appID: appID, themeName: theme.name, drm: theme.sourcedRepoTheme)
            }
        }
        
        return icons
    }
    
    private func neededChanges() throws -> [AppIconChange] {
        let apps = try ApplicationManager.getApps()
        let themedIcons = try themedIcons()
        var appChanges: [AppIconChange] = []
        
        for app in apps {
            guard !app.pngIconPaths.isEmpty else { continue }
        
            if let themedIcon = themedIcons[app.bundleIdentifier] {
                // add app to changes to be themed
                appChanges.append(.init(app: app, icon: themedIcon))
            } else if app.bundleIdentifier == "com.apple.mobiletimer", let themedIcon = themedIcons["ClockIconBackgroundSquare"] {
                // add app to changes to be themed
                appChanges.append(.init(app: app, icon: themedIcon))
            } else {
                var bundleComponents = app.bundleIdentifier.components(separatedBy: ".")
                bundleComponents.removeLast()
                if let themedIcon = themedIcons[bundleComponents.joined(separator: ".")] {
                    // sideloaded apps
                    appChanges.append(.init(app: app, icon: themedIcon))
                } else {
                    // restore
                    appChanges.append(.init(app: app, icon: nil))
                }
            }
        }
        
        
        return appChanges
    }
    
    func getAppIcons(for appIDs: [String], theme: IconTheme) -> [UIImage?] {
        var images: [UIImage?] = []
        guard let iconImages = try? FileManager.default.contentsOfDirectory(at: theme.url, includingPropertiesForKeys: nil) else { return [] }
        for iconImage in iconImages {
            let appID = getAppIDFromIconFile(iconImage)
            guard appIDs.contains(appID) else { continue }
            let themedIcon = ThemedIcon(appID: appID, themeName: theme.name, drm: theme.sourcedRepoTheme)
            if let iconData = try? themedIcon.iconData() {
                images.append(UIImage(data: iconData))
            } else {
                images.append(nil)
            }
        }
        return images
    }
    
    
    // MARK: Backups
    public func backUpIcons() {
        
    }
}


