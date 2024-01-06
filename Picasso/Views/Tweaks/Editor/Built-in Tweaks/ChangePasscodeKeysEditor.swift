//
//  DynamicIslandEditor.swift
//  Picasso
//
//  Created by sourcelocation on 09/08/2023.
//

import SwiftUI
import NavigationBackport

struct ChangePasscodeKeysEditor: View {
    
    @StateObject var package: LocalPackage = .init(tweak: .init(operations: [
        DynamicIslandOperation()
    ]), info: .init(bundleID: "\(UserDefaults.standard.string(forKey: "bundleID") ?? "com.\(UserDefaults.standard.string(forKey: "username")?.lowercased() ?? "example")").ChangePasscodeKeys", name: "ChangePasscodeKeysEditor", author: UserDefaults.standard.string(forKey: "authorName") ?? UserDefaults.standard.string(forKey: "username") ?? "You!", version: "1.0", iconURL: nil), prefs: .init(preferences: []), url: nil)

    var body: some View {
        List {
            Section(header: Label("Device feature", systemImage: "wrench.adjustable")) {
                Text("No options to configure")
            }
            // next
            NavigationLink(destination: TweakCompileReviewView(package: package)) {
                Label("Next", systemImage: "arrow.right.circle")
            }
            .tint(.accentColor)
        }.navigationTitle("ChangePasscodeKeys")
    }
}

struct ChangePasscodeKeysEditor_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasscodeKeysEditor()
    }
}
