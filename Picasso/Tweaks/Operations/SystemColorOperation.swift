//
//  SystemColorOperation.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-10-03.
//
import Foundation
import SwiftUI
import URLBackport

public class SystemColorOperation: Operation {

    public init() {
        super.init(type: .accentOperation)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try super.init(from: decoder)
    }
    

    public override func perform(tweakURL: URL, preferences: [String: Any]) throws {
        print(preferences)
        var replaceAll: Bool = false
        if let replaceAllPref = preferences["replaceAll"] as? Bool {
            replaceAll = replaceAllPref
        } else {
            print("[AccentColor] Warning: replaceAll not present")
            replaceAll = false
        }
        
        guard let accentColorDict = preferences["accentColor"] as? [String: Any] else {
            throw "Failed to get color value from preferences. Go to preference of the tweak and select a color"
        }
        
        guard let notifColorDict = preferences["notifColor"] as? [String: Any] else {
            throw "Failed to get color value from preferences. Go to preference of the tweak and select a color"
        }
        
        let jsonDecoder = JSONDecoder()
        
        let accentJsonData = try JSONSerialization.data(withJSONObject: accentColorDict, options: [])
        var accentColor = UIColor(try jsonDecoder.decode(Color.self, from: accentJsonData))
        
        let notifJsonData = try JSONSerialization.data(withJSONObject: notifColorDict, options: [])
        var notifColor = UIColor(try jsonDecoder.decode(Color.self, from: notifJsonData))
        
        do {
            // TODO: Make this better
            if replaceAll {
                // do stuff idk
            }
            
            // accent color
            try replaceColorInFile(color: accentColor, byteOffset: 17736, fileName: "LightStandard")
            try replaceColorInFile(color: accentColor, byteOffset: 19128, fileName: "DarkStandard")
            try replaceColorInFile(color: accentColor, byteOffset: 16232, fileName: "LightVibrantStandard")
            try replaceColorInFile(color: accentColor, byteOffset: 16088, fileName: "DarkVibrantStandard")
            try replaceColorInFile(color: accentColor, byteOffset: 16360, fileName: "LightIncreasedContrast")
            try replaceColorInFile(color: accentColor, byteOffset: 18200, fileName: "DarkIncreasedContrast")
            
            // notif color
            try replaceColorInFile(color: notifColor, byteOffset: 19496, fileName: "LightStandard")
            try replaceColorInFile(color: notifColor, byteOffset: 20888, fileName: "DarkStandard")
            try replaceColorInFile(color: notifColor, byteOffset: 17832, fileName: "LightVibrantStandard")
            try replaceColorInFile(color: notifColor, byteOffset: 17688, fileName: "DarkVibrantStandard")
            try replaceColorInFile(color: notifColor, byteOffset: 18120, fileName: "LightIncreasedContrast")
            try replaceColorInFile(color: notifColor, byteOffset: 19960, fileName: "DarkIncreasedContrast")
        } catch {
            throw error
        }
        
    }
    
    func replaceColorInFile(color: UIColor, byteOffset: Int, fileName: String) throws {
        let components: [UInt8] = color.toHex(includeAlpha: true, bgra: true) // wow thats inefficient
        print("[AccentColor] \(components)")
        if let url: URL = Bundle.main.url(forResource: fileName, withExtension: "car") {
            if var carData: Data = try .init(contentsOf: url) {
                print("[AccentColor] orig: \(carData)")
                let byteRange = byteOffset..<byteOffset + components.count
                carData.replaceSubrange(byteRange, with: components)
                print("[AccentColor] new: \(carData)")
                do {
                    try ExploitKit.shared.Overwrite(at: .init(string: "/System/Library/PrivateFrameworks/CoreUI.framework/DesignLibrary-iOS.bundle/iOSRepositories/\(fileName).car")!, with: carData)
                } catch {
                    print("[AccentColor] File overwrite failed: \(error.localizedDescription)")
                    throw "File overwrite failed: \(error.localizedDescription)"
                }
            } else {
                print("[AccentColor] Could not get Data from bundled car!")
                throw "Could not get Data from bundled car!"
            }
        } else {
            print("[AccentColor] Could not get URL for bundled car!")
            throw "Could not get URL for bundled car!"
        }
    }
}

