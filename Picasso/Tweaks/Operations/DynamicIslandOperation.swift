//
//  RemoveOperation.swift
//  Picasso
//
//  Created by sourcelocation on 07/08/2023.
//

import UIKit
import URLBackport

public class DynamicIslandOperation: Operation {

    public init() {
        super.init(type: .dynamicIsland)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    public override func perform(tweakURL: URL, preferences: [String: Any]) throws {
        let url = URL.backport(filePath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist")
        let data = try Data(contentsOf: url)
        var plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
        plist.replaceValues(where: { $0 == "ArtworkDeviceSubType" }, with: 2556)

        let serializedPlist = try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0)
        
        try ExploitKit.shared.Overwrite(at: url, with: serializedPlist)
    }

    public override func revert(tweakURL: URL) throws {
        let url = URL.backport(filePath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist")
        let data = try Data(contentsOf: url)
        var plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
        
        let originalSubtype = try getOriginalDeviceSubtype()
        plist.replaceValues(where: { $0 == "ArtworkDeviceSubType" }, with: originalSubtype)

        let serializedPlist = try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0)

        try ExploitKit.shared.Overwrite(at: url, with: serializedPlist)
    }
}

func getOriginalDeviceSubtype() throws -> Int {
    var canUseStandardMethod: [String] = ["10,3", "10,4", "10,6", "11,2", "11,4", "11,6", "11,8", "12,1", "12,3", "12,5", "13,1", "13,2", "13,3", "13,4", "14,4", "14,5", "14,2", "14,3", "14,7", "14,8", "15,2"]
    let predefinedSubtypes: [String: Int] = [
        "iPhone8,1": 568,
        "iPhone8,2": 570,
        "iPhone8,4": 568,
        "iPhone9,1": 569,
        "iPhone9,3": 569,
        "iPhone9,2": 570,
        "iPhone9,4": 570,
        "iPhone10,1": 569,
        "iPhone10,4": 569,
        "iPhone10,2": 570,
        "iPhone10,5": 570,
        "iPhone14,6": 569
    ]
    for (i, v) in canUseStandardMethod.enumerated() {
        canUseStandardMethod[i] = "iPhone" + v
    }
    
    var deviceSubType: Int = 0
    let deviceModel: String = UIDevice().machineName

    print("[DynamicIsland] Device Model: " + deviceModel)
    if canUseStandardMethod.contains(deviceModel) {
        // can use device bounds
        deviceSubType = Int(UIScreen.main.nativeBounds.height)
    } else if predefinedSubtypes[deviceModel] != nil {
        deviceSubType = predefinedSubtypes[deviceModel]!
    }
    
    
    
    // set the subtype
    print("[DynamicIsland] Device SubType: " + String(deviceSubType))
    if deviceSubType >= 0 {
        return deviceSubType
    } else {
        throw "Couldn't find device subtype"
    }
}
