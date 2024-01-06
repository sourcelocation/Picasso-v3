//
//  ColorOperation.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-09.
//

import Foundation
import SwiftUI
import URLBackport

public class ColorOperation: Operation {
    
    @Published var springboardElement: ColorType
    
    public enum ColorType: String, Hashable, Codable {
        case dock = "dock"
        case folder = "folder"
        case ccbg = "ccbg"
        case cctile = "cctile"
        case bannerbg = "bannerbg"
        case bannershadow = "bannershadow"
    }
    
    init (type: ColorType) {
        self.springboardElement = type
        super.init(type: .springboardColor)
    }

    enum CodingKeys: String, CodingKey {
        case springboardElement = "springboardElement"
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(springboardElement, forKey: .springboardElement)
        try super.encode(to: encoder)
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        springboardElement = try container.decode(ColorType.self, forKey: .springboardElement)
        try super.init(from: decoder)
    }
    
    public static func pathFromColorType(_ type: ColorType) -> [URL] {
        switch type {
        // TODO: Individual light/dark mode options?
        // Best to do [light mode url, dark mode url] for future things
        case .dock:
            return [URL(string: "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe")!, URL(string: "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe")!]
        case .folder:
            return [URL(string: "System/Library/PrivateFrameworks/SpringBoardHome.framework/folderDark.materialrecipe")!, URL(string: "System/Library/PrivateFrameworks/SpringBoardHome.framework/folderLight.materialrecipe")!]
        case .ccbg:
            return [URL(string: "/System/Library/PrivateFrameworks/CoreMaterial.framework/modulesBackground.materialrecipe")!]
        case .cctile:
            return [URL(string: "/System/Library/PrivateFrameworks/CoreMaterial.framework/modules.materialrecipe")!]
        case .bannerbg:
            return [URL(string: "/System/Library/PrivateFrameworks/CoreMaterial.framework/platters.materialrecipe")!, URL(string: "/System/Library/PrivateFrameworks/CoreMaterial.framework/plattersDark.materialrecipe")!]
        case .bannershadow:
            return [URL(string: "System/Library/PrivateFrameworks/PlatterKit.framework/platterVibrantShadowLight.visualstyleset")!, URL(string: "System/Library/PrivateFrameworks/PlatterKit.framework/platterVibrantShadowDark.visualstyleset")!]
        }
    }

    public static func nameFromColorType(_ type: ColorType) -> String {
        switch type {
        case .dock:
            return "Dock"
        case .folder:
            return "Folder"
        case .ccbg:
            return "Control Center BG"
        case .cctile:
            return "Control Center Tile"
        case .bannerbg:
            return "Notification Banner Background"
        case .bannershadow:
            return "Notification Banner Shadow"
        }
    }

    public override func perform(tweakURL: URL, preferences: [String: Any]) throws {
        guard let colorDict =  preferences["color"] as? [String: Any] else {
            throw "Failed to get color value from preferences. Go to preference of the tweak and select a color"
        }
        let jsonData = try JSONSerialization.data(withJSONObject: colorDict, options: [])
        let decoder = JSONDecoder()
        let color = try decoder.decode(Color.self, from: jsonData)

        guard let blur = preferences["blur"] as? Int else {
            throw "Failed to get blur value from preferences. Go to preference of the tweak and select a blur"
        }

        print("[SBColor] \(color)")
        let ciColor = CIColor(color: UIColor(color))

        let urls = ColorOperation.pathFromColorType(springboardElement)

        for url in urls {
            var dict: [String: Any] = [:]
            addColor(dict: &dict, color: ciColor, blur: blur)
            print(url)
            let origData = try Data(contentsOf: .backport(filePath: url.path))
            print(origData)
            let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
            let newData = insaneNewPaddingMethodUsingBytes(data, padToBytes: origData.count)
//            try addEmptyData(matchingSize: origData.count, to: dict) // padDataWithPaddingBytes(data, padToBytes: origData.count - data.count)
            print(newData)
            try ExploitKit.shared.Overwrite(at: url, with: newData)
        }
    }
    
    public override func revert(tweakURL: URL) throws {
//        Haptic.shared.notify(.warning)
//        DispatchQueue.main.async {
//            UIApplication.shared.alert(title: "Notice", body: "Please respring to revert changes.")
//        }
    }
    
    func addColor(dict: inout [String: Any], color: CIColor, blur: Int) {
        // dict["baseMaterial"]["tinting"]["tintColor"] 
        // make sure we have these keys, and if not, add each dictionary
        var baseMaterialDict = dict["baseMaterial"] as? [String: Any] ?? [:]
        var tintingDict = baseMaterialDict["tinting"] as? [String: Any] ?? [:]
        
        let colorDict = [
            "red": min(1,max(0,color.red)),
            "green": min(1,max(0,color.green)),
            "blue": min(1,max(0,color.blue)),
            "alpha": min(1,max(0,color.alpha)),
        ]


        tintingDict["tintColor"] = colorDict
        tintingDict["tintAlpha"] = color.alpha
        baseMaterialDict["tinting"] = tintingDict
        baseMaterialDict["materialFiltering"] = ["blurRadius": blur]
        dict["baseMaterial"] = baseMaterialDict
        dict["baseMaterial"] = baseMaterialDict
        
        if springboardElement == .cctile || springboardElement == .ccbg {
            dict["styles"] = [
                "fill": "moduleFill",
                "stroke": "moduleStroke"
            ]
            dict["materialSettingsVersion"] = 2
        }
    }
}
