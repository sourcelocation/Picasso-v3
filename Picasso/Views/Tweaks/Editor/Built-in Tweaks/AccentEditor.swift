//
//  AccentEditor.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-11.
//

import SwiftUI

struct AccentEditor: View {
    @State var color: Color = Color(UIColor.systemBlue)
    
    private var package: LocalPackage {
        return .init(tweak: .init(operations: [AccentOperation()]), info: .init(bundleID: "\(UserDefaults.standard.string(forKey: "bundleID") ?? "com.\(UserDefaults.standard.string(forKey: "username")?.lowercased() ?? "example")").accent",
                                                                              name: "Accent Color",
                                                                              author: UserDefaults.standard.string(forKey: "authorName") ?? UserDefaults.standard.string(forKey: "username") ?? "You!",
                                                                              version: "1.0",
                                                                              iconURL: nil), prefs: .init(preferences: [
                                                                                .init(key: "replaceAll", valueType: "bool", title: "Change all Colors", description: ""),
                                                                                 .init(key: "color", valueType: "color", title: "Color", description: "Changes color of this UI element to the specified color. Supports opacity.")]),
                                                                  url: nil)
    }
    
    var body: some View {
        List {
            Section{Text("No options to configure").foregroundColor(.secondary)}
            Section {
                NavigationLink(destination: TweakCompileReviewView(package: package)) {
                    Label("Next", systemImage: "arrow.right.circle")
                }
                .tint(.accentColor)
            }
        }
        .navigationTitle("Accent Color")
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

//#Preview {
//    AccentEditor()
//}
