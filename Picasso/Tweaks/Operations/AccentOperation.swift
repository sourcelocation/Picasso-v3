//
//  AccentOperation.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-17.
//

import Foundation
import SwiftUI
import URLBackport

public class AccentOperation: Operation {

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
        
        guard let colorDict = preferences["color"] as? [String: Any] else {
            throw "Failed to get color value from preferences. Go to preference of the tweak and select a color"
        }
        let jsonData = try JSONSerialization.data(withJSONObject: colorDict, options: [])
        let decoder = JSONDecoder()
        var color = UIColor(try decoder.decode(Color.self, from: jsonData))
        
        do {
            // TODO: Make this better
            if replaceAll {
                // do stuff idk
            }
            try replaceColorInFile(color: color, byteOffset: 17736, fileName: "LightStandard")
            try replaceColorInFile(color: color, byteOffset: 19128, fileName: "DarkStandard")
            try replaceColorInFile(color: color, byteOffset: 16232, fileName: "LightVibrantStandard")
            try replaceColorInFile(color: color, byteOffset: 16088, fileName: "DarkVibrantStandard")
            try replaceColorInFile(color: color, byteOffset: 16360, fileName: "LightIncreasedContrast")
            try replaceColorInFile(color: color, byteOffset: 18200, fileName: "DarkIncreasedContrast")
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

