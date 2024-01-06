//
//  TweakApplier.swift
//  Picasso
//
//  Created by sourcelocation on 05/08/2023.
//

import Foundation

public class TweakApplier {
    static public var shared = TweakApplier()
    private var tweakManager = TweakManager.shared

    public func applyTweaks() throws {
        let installedPackages = tweakManager.getInstalledPackages()
        for package in installedPackages {
            do {
                try applyTweak(package: package)
            } catch {
                print("[TweakApplier] \(error)")
                throw "Failed to apply tweak \(package.info.name). \n\nError:\n \(error.localizedDescription)"
            }
        }
    }

    public func applyTweak(package: LocalPackage) throws {
        // map prefs to [String: Any], retaining keys
        let prefsAny: [String: Any] = package.prefs.mapValues { $0.value }

        // apply tweak
        for operation in package.tweak.operations {
            try operation.perform(tweakURL: package.url!, preferences: prefsAny)
        }
    }
}



