//
//  TweakManager.swift
//  Picasso
//
//  Created by sourcelocation on 04/08/2023.
//

import SwiftUI
import ZIPFoundation
import Combine

/// Responsible for updating, installing Packages. Tracks updates
public class TweakManager: ObservableObject {

    static var shared = TweakManager()
    
    @Published var installedPackages: [LocalPackage] = []

    var fetcher = TweakRepoFetcher.shared

    private init() {
        try? FileManager.default.createDirectory(at: TweakManager.tweaksDirectory, withIntermediateDirectories: true, attributes: nil)
        updateInstalledPackages()
    }
    
    static let tweaksDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Tweaks")
    
    /// Packages/Compresses a LocalPackage.
    /// Returns a URL to a temporary package file which can then be used by something like a share sheet.
    public func exportPackage(_ package: LocalPackage) async throws -> URL {
        
        // for convenience's sake
        let fm: FileManager = FileManager.default
        
        // get package url
        guard let packageURL: URL = package.url else {
            // since package.url is optional, throw error in the rare case we cant find package url
            throw "Error exporting package. Could not find saved package URL."
        }
        
        // define this to make life easier later
        // use uuid to prevent only being able to export once
        let tempURL: URL = .init(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString, conformingTo: .directory)
        
        do {
            try fm.createDirectory(at: tempURL, withIntermediateDirectories: true)
        } catch {
            throw "Error exporting package. \(error.localizedDescription)"
        }
        
        let finalURL: URL = tempURL.appendingPathComponent(package.info.bundleID + ".picasso")
        
        do {
            // this is the magic
            try fm.zipItem(at: packageURL, to: finalURL)
        } catch {
            // throw any errors
            throw "Error exporting package. \(error.localizedDescription)"
        }
        
        return finalURL
    }
    
    public func installPackage(_ package: RepoPackage) async throws {
        guard !FileManager.default.fileExists(atPath: TweakManager.tweaksDirectory.appendingPathComponent(package.bundleID).path) else { throw "The tweak \(package.name) (\(package.bundleID) is already installed." }
        func removeWeirdFiles() {
            // remove __MACOSX
            let macosxURL = TweakManager.tweaksDirectory.appendingPathComponent("__MACOSX")
            try? FileManager.default.removeItem(at: macosxURL)
        }
        
        removeWeirdFiles()
        
        let (data, _) = try await URLSession.shared.data(from: package.downloadURL)
        
        // save package to tmp
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(package.bundleID + ".zip")
        try data.write(to: tmpURL)
        
        
        // unzip package
        let unzipURL = TweakManager.tweaksDirectory
        try FileManager.default.unzipItem(at: tmpURL, to: unzipURL)
        
        removeWeirdFiles()
        
        
//        // save manifest as info.json
//        let manifestURL = unzipURL.appendingPathComponent(package.bundleID).appendingPathComponent("info.json")
//        let info = LocalPackageManifest(bundleID: package.bundleID,
//                                            name: package.name,
//                                            author: package.author,
//                                            version: package.version,
//                                            iconURL: package.iconURL
//        )
//        let encoder = JSONEncoder()
//        try (try encoder.encode(info)).write(to: manifestURL)
        
        // remove zip
        try FileManager.default.removeItem(at: tmpURL)

        updateInstalledPackages()
    }

    public func installLocalPackage(_ package: LocalPackage) throws {
        // remove
        try? FileManager.default.removeItem(at: TweakManager.tweaksDirectory.appendingPathComponent(package.info.bundleID))

        try FileManager.default.copyItem(at: package.url!, to: TweakManager.tweaksDirectory.appendingPathComponent(package.info.bundleID))

        updateInstalledPackages()
    }
    
    public func removePackage(_ installedPackage: LocalPackage, force: Bool) throws {
        guard let url = installedPackage.url else { throw "Package not installed" }

        if force {
            try? FileManager.default.removeItem(at: url)
            updateInstalledPackages()
        }
        try installedPackage.revert()
        if !force {
            try? FileManager.default.removeItem(at: url)
            updateInstalledPackages()
        }

    }
    
    public func updateAll() {
        
    }
    
    public func updateInstalledPackages() {
        DispatchQueue.main.async {
            self.installedPackages = self.getInstalledPackages()
        }
    }

    public func getPackages(at url: URL) -> [LocalPackage] {
        let installedPackages = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        return installedPackages?.compactMap { url in
            let manifestURL = url.appendingPathComponent("info.json")
            guard let data = try? Data(contentsOf: manifestURL) else { return nil }
            let decoder = JSONDecoder()
            guard let manifest = try? decoder.decode(LocalPackageManifest.self, from: data) else { return nil }
            
            let tweakManifestURL = url.appendingPathComponent("tweak.json")
            guard let tweakData = try? Data(contentsOf: tweakManifestURL) else { return nil }
            guard let tweakManifest = try? decoder.decode(LocalPackageTweakManifest.self, from: tweakData) else { return nil }

            let prefsConfigURL = url.appendingPathComponent("prefs.json")
            var prefsConfig = TweakPrefsConfig(preferences: [])
            if let prefsData = try? Data(contentsOf: prefsConfigURL), let prefs = try? decoder.decode(TweakPrefsConfig.self, from: prefsData) {
                prefsConfig = prefs
            }

            return LocalPackage(tweak: tweakManifest, info: manifest, prefs: prefsConfig, url: url)
        } ?? []
    }
    
    public func getInstalledPackages() -> [LocalPackage] {
        return getPackages(at: TweakManager.tweaksDirectory)
    }
    
    /// Returns package ids with an available update
    public func updates() -> [String] {
        let repos = fetcher.repos
        let installedPackages = self.getInstalledPackages()

        var updates: [String] = []

        for repo in repos {
            guard let repo else { continue }
            for package in repo.packages {
                guard let installedPackage = installedPackages.first(where: { $0.info.bundleID == package.bundleID }) else { continue }
                if package.version > installedPackage.info.version {
                    updates.append(package.bundleID)
                }
            }
        }

        return updates
    }
}

