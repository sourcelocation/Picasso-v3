//
//  LocalPackage.swift
//  Picasso
//
//  Created by sourcelocation on 10/08/2023.
//

import Combine
import SwiftUI
import AnyCodable

public class LocalPackage: Codable, ObservableObject, Identifiable {
    public let id = UUID()
    
    @Published var tweak: LocalPackageTweakManifest
    @Published var info: LocalPackageManifest
    @Published var url: URL?
    
    @Published var prefsConfig: TweakPrefsConfig
    @Published var prefs: [String: AnyCodable]
    
    var cancellables : Set<AnyCancellable> = []
    
    public init(tweak: LocalPackageTweakManifest, info: LocalPackageManifest, prefs: TweakPrefsConfig, url: URL?) {
        self.tweak = tweak
        self.info = info
        self.url = url
        self.prefsConfig = prefs
        self.prefs = [:]
        
        self.loadPrefs()
        
        cancellables.insert(self.tweak.$operations.sink(
            receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            }
        ))
        cancellables.insert(self.prefsConfig.$preferences.sink(
            receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            }
        ))
        
        
        cancellables.insert(self.$prefs.sink(
            receiveValue: { [weak self] out in
                guard url != nil else { return }
                self?.objectWillChange.send()
                self?.savePrefs(prefs: out)
            }
        ))
    }
    
    enum CodingKeys: String, CodingKey {
        case tweak = "tweak"
        case info = "info"
        case prefsConfig = "prefsConfig"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tweak = try container.decode(LocalPackageTweakManifest.self, forKey: .tweak)
        info = try container.decode(LocalPackageManifest.self, forKey: .info)
        prefsConfig = try container.decode(TweakPrefsConfig.self, forKey: .prefsConfig)
        prefs = [:]
        loadPrefs()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tweak, forKey: .tweak)
        try container.encode(info, forKey: .info)
        try container.encode(prefsConfig, forKey: .prefsConfig)
    }
    
    func save(to url: URL) {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        try! (try! encoder.encode(self.info)).write(to: url.appendingPathComponent("info.json"))
        try! (try! encoder.encode(self.tweak)).write(to: url.appendingPathComponent("tweak.json"))
        try! (try! encoder.encode(self.prefsConfig)).write(to: url.appendingPathComponent("prefs.json"))
    }
    
    func revert() throws {
        for operation in tweak.operations {
            try operation.revert(tweakURL: url!)
        }
    }
    
    static let prefsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Prefs")
    
    func savePrefs(prefs: [String : AnyCodable]) {
        try? FileManager.default.createDirectory(at: LocalPackage.prefsDirectory, withIntermediateDirectories: true, attributes: nil)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        try! (try! encoder.encode(prefs)).write(to: LocalPackage.prefsDirectory.appendingPathComponent(self.info.bundleID + ".json"))
    }
    
    private func loadPrefs() {
        try? FileManager.default.createDirectory(at: LocalPackage.prefsDirectory, withIntermediateDirectories: true, attributes: nil)

        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: LocalPackage.prefsDirectory.appendingPathComponent(self.info.bundleID + ".json"))
            self.prefs = try decoder.decode([String: AnyCodable].self, from: data)
        } catch {
            self.prefs = [:]
        }
    }
}


/*
 
 required public init(from decoder: Decoder) throws {
 let container = try decoder.container(keyedBy: CodingKeys.self)
 preferences = try container.decode([String: AnyDecodable].self, forKey: .preferences)
 type = try container.decode(PrefsType.self, forKey: .type)
 }
 
 public func encode(to encoder: Encoder) throws {
 var container = encoder.container(keyedBy: CodingKeys.self)
 try container.encode((preferences as! [String: AnyEncodable]), forKey: .preferences)
 try container.encode(type, forKey: .type)
 }
 
 */
