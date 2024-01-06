//
//  TweakRepoFetcher.swift
//  Picasso
//
//  Created by sourcelocation on 04/08/2023.
//

import Foundation
import Combine


public class TweakRepoFetcher: ObservableObject {
    

    
    static var shared = TweakRepoFetcher()
        
    public var manifestURLs: [String] {
        get {
            (UserDefaults.standard.array(forKey: "manifestURLs") as? [String]) ?? [
                "https://bomberfish.ca/PicassoRepos/Essentials/manifest.json",
                "https://raw.githubusercontent.com/sourcelocation/Picasso-test-repo/main/manifest.json"
            ]
        } set {
            UserDefaults.standard.set(newValue, forKey: "manifestURLs")
        }
    }

    @Published public var repos: [Repo?] = []
    
    init() {
        print("[TweakRepoFetcher] \(self.manifestURLs)")
        readCacheFromDisk()
    }

    /// Downloads manifest for all repos and updates the repos array
    public func updateRepos() async throws {
        print("[TweakRepoFetcher] Updating repos!")
        var manifests: [RepoManifest?] = []
        var errors: [String] = []
        
        for manifestURL in manifestURLs {
            do {
                guard let url = URL(string: manifestURL) else { throw "Invalid URL" }
                let parsedManifest: RepoManifest = try await parseManifest(url)
                
                for package in parsedManifest.packages {
                    package.prepareURLs(repoURL: url.deletingLastPathComponent())
                }
                
                manifests.append(parsedManifest)
            } catch {
                let dummy = RepoManifest(spec: "1.0", packages: [], iconPath: "", name: "Invalid - \(manifestURL)", description: "Invalid repo. \(error.localizedDescription)")
                dummy.url = .init(string: "manifestURL")
                manifests.append(dummy)
                errors.append("Error parsing \(manifestURL): \(error)")
                print("[TweakRepoFetcher] Error parsing \(manifestURL): \(error)")
            }
        }

        repos = manifests.map { $0 != nil ? Repo(manifest: $0!) : nil }
        
        if !errors.isEmpty {
            throw errors.joined(separator: "\n")
        }
    }
    
    public func parseManifest(_ url: URL) async throws -> RepoManifest {
        print("[TweakRepoFetcher] Parsing manifest \(url.absoluteString)")
        let request = URLRequest(url: url)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let manifest = try decoder.decode(RepoManifest.self, from: data)
            //guard let manifest = try decoder.decode(RepoManifest.self, from: data) else { manifests.append(nil); continue }
            manifest.url = url
            return manifest
        } catch {
            throw error
        }
    }
    
//    public func parseManifestSynchronously(_ url: URL) throws -> RepoManifest {
//    }

    // why do these exist
    private func writeCacheToDisk() {
        print("[!!!] [TweakRepoFetcher] Empty function writeCacheToDisk called!")
    }
    private func readCacheFromDisk() {
        print("[!!!] [TweakRepoFetcher] Empty function readCacheFromDisk called!")
    }
}

/// A local repo.
public struct Repo: Codable, Identifiable {
    public var id = UUID()
    var name: String
    var url: URL
    var manifestURL: URL {
        url.appendingPathComponent("manifest.json")
    }
    var iconURL: URL
    
    var packages: [RepoPackage]
    
    var description: String

    init(manifest: RepoManifest) {
        name = manifest.name
        url = manifest.url
        iconURL = manifest.url.deletingLastPathComponent().appendingPathComponent(manifest.iconPath)
        packages = manifest.packages
        description = manifest.description
    }
}

/// Manifest for a repo
public class RepoManifest: Codable {
    var url: URL!
    var spec: String
    var packages: [RepoPackage]
    var iconPath: String
    var name: String
    var description: String

    enum CodingKeys: String, CodingKey {
        case packages = "packages"
        case iconPath = "icon"
        case name = "name"
        case description = "description"
        case spec = "spec"
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        packages = try container.decode([RepoPackage].self, forKey: .packages)
        iconPath = try container.decode(String.self, forKey: .iconPath)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        spec = try container.decode(String.self, forKey: .spec)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(packages, forKey: .packages)
        try container.encode(iconPath, forKey: .iconPath)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(spec, forKey: .spec)
    }

    init(spec: String, packages: [RepoPackage], iconPath: String, name: String, description: String) {
        self.spec = spec
        self.packages = packages
        self.iconPath = iconPath
        self.name = name
        self.description = description
    }
}

