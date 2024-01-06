//
//  ColorEditor.swift
//  Picasso
//
//  Created by sourcelocation on 05/08/2023.
//

import SwiftUI
import NavigationBackport

struct ColorEditor: View {
    
    @StateObject var operation = ColorOperation(type: .bannerbg)
    
    private var package: LocalPackage {
        return .init(tweak: .init(operations: [operation]),
                     info: .init(bundleID: "\(UserDefaults.standard.string(forKey: "bundleID") ?? "com.\(UserDefaults.standard.string(forKey: "username")?.lowercased() ?? "example")").\(operation.springboardElement.rawValue)",
                                 name: ColorOperation.nameFromColorType(operation.springboardElement),
                                 author: UserDefaults.standard.string(forKey: "authorName") ?? UserDefaults.standard.string(forKey: "username") ?? "You!",
                                 version: "1.0",
                                 iconURL: nil), prefs: .init(preferences: [
                                    .init(key: "color", valueType: "color", title: "Color", description: "Changes color of this UI element to the specified color. Supports opacity."),
                                    .init(key: "blur", valueType: "int", title: "Blur", description: "Changes blur of this UI element if applicable. Set to 0 to remove the blur completely."),
                                 ]),
                     url: nil)
    }
    
    /// Initially selected
    var type: ColorOperation.ColorType
    
    var body: some View {
        List {
            Section(header: Label("Compile-time options", systemImage: "wrench.adjustable"), footer: Label("You can change the color in the Tweak's preferences in the Installed Tab.", systemImage: "info.circle")) {
                Picker("Type", selection: $operation.springboardElement) {
                    Text("Notification Banner background").tag(ColorOperation.ColorType.bannerbg)
                    Text("Banner shadow").tag(ColorOperation.ColorType.bannershadow)
                    Text("Control Center background").tag(ColorOperation.ColorType.ccbg)
                    Text("Control Center tile").tag(ColorOperation.ColorType.cctile)
                    Text("Dock background").tag(ColorOperation.ColorType.dock)
                    Text("Folder background").tag(ColorOperation.ColorType.folder)
                }
            }
            
            Section {
                NavigationLink(destination: TweakCompileReviewView(package: package)) {
                    Label("Next", systemImage: "arrow.right.circle")
                }
                .tint(.accentColor)
            }
        }
        .onAppear {
            operation.springboardElement = type
        }
        .navigationTitle("Editing Color")
    }
}

struct ColorEditor_Previews: PreviewProvider {
    static var previews: some View {
        ColorEditor(type: .bannerbg)
    }
}
