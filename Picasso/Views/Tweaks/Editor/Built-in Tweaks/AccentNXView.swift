//
//  AccentNXView.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-10-03.
//

import SwiftUI

struct AccentNXView: View {
    @State var color: Color = .init(UIColor.systemBlue)

    private var package: LocalPackage {
        return .init(tweak: .init(operations: [SystemColorOperation()]), info: .init(bundleID: "\(UserDefaults.standard.string(forKey: "bundleID") ?? "com.\(UserDefaults.standard.string(forKey: "username")?.lowercased() ?? "example")").accentnx",
                                                                                name: "Accent Color NX",
                                                                                author: UserDefaults.standard.string(forKey: "authorName") ?? UserDefaults.standard.string(forKey: "username") ?? "You!",
                                                                                version: "1.0",
                                                                                iconURL: nil), prefs: .init(preferences: [
                         .init(key: "replaceAll", valueType: "bool", title: "Change all Colors", description: ""),
                         .init(key: "accentColor", valueType: "color", title: "Accent Color", description: "Changes the system accent color to the specified color. Supports opacity."), .init(key: "color", valueType: "color", title: "Accent Color", description: "Changes color of this UI element to the specified color. Supports opacity."),
                         .init(key: "notifColor", valueType: "color", title: "Notification Badge Color", description: "Changes color of notification badge to the specified color. Supports opacity."),
                     ]),
                     url: nil)
    }

    var body: some View {
        List {
            Section { Text("Accent Color NX is very unstable and subject to change! Use at your own risk!").foregroundColor(.init(red: 1, green: 0, blue: 0))}
            Section { Text("No options to configure").foregroundColor(.secondary) }
            Section {
                NavigationLink(destination: TweakCompileReviewView(package: package)) {
                    Label("Next", systemImage: "arrow.right.circle")
                }
                .tint(.accentColor)
            }
        }
        .navigationTitle("Accent Color NX")
    }

//    func getColor() -> Color {
//        let path: URL = URL(string: "/System/Library/PrivateFrameworks/CoreUI.framework/DesignLibrary-iOS.bundle/iOSRepositories/LightStandard.car")!
//        var data: Data? = nil
//        do {
//            data = try .init(contentsOf: path)
//        } catch {
//            print("🔴 data get failed: \(error.localizedDescription)")
//            return .accentColor
//        }
//        if data == nil {
//            print("🔴 data == nil!")
//            return .accentColor
//        } else {
//            print("🔴 data != nil!")
//            let offset = 17736
//            let byteRange = offset..<offset + 4
//            if let subdata = data?.subdata(in: byteRange) {
//                print("🟢 \(subdata)")
//                return .blue
//            } else {
//                print("🔴 subdata is no")
//                return .accentColor
//            }
//        }
//    }
}

// #Preview {
//    AccentEditor()
// }
