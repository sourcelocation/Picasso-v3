//
//  TweakPreferencesView.swift
//  Picasso
//
//  Created by sourcelocation on 10/08/2023.
//

import SwiftUI
import UIKit
import AnyCodable

struct TweakPreferencesView: View {
    @ObservedObject var package: LocalPackage
    
    var body: some View {
        Form {
            if package.prefsConfig.preferences.isEmpty {
                Text("No options to configure")
                    .foregroundColor(.secondary)
            } else {
                ForEach(package.prefsConfig.preferences) { preferenceRow in
                    let description = preferenceRow.description
                    
                    if let description = description {
                        Section(footer: Text(description)) {
                            Row(package: package, preferenceRow: preferenceRow)
                        }
                    } else {
                        Row(package: package, preferenceRow: preferenceRow)
                    }
                }
            }
        }
        .navigationTitle("Preferences")
    }
    
    struct Row: View {
        @ObservedObject var package: LocalPackage
        @ObservedObject var preferenceRow: TweakPreference
        
        var body: some View {
            let type: String = preferenceRow.valueType
            switch type {
            case "bool":
                Toggle(preferenceRow.title, isOn: Binding<Bool>(
                    get: {
                        self.package.prefs[preferenceRow.key]?.value as? Bool ?? false
                    },
                    set: { newValue in
                        self.package.prefs[preferenceRow.key] = .init(newValue)
                    }
                ))
                .tint(.accentColor)
            case "int":
                HStack {
                    let binding = Binding<Int>(
                        get: {
                            self.package.prefs[preferenceRow.key]?.value as? Int ?? 0
                        },
                        set: { newValue in
                            self.package.prefs[preferenceRow.key] = .init(newValue)
                        }
                    )
                    Stepper("\(preferenceRow.title): \(package.prefs[preferenceRow.key]?.value as? Int ?? 0)", value: binding)
//                        .labelsHidden()
                }
            case "double":
                Stepper(preferenceRow.title, value: Binding<Double>(
                    get: {
                        self.package.prefs[preferenceRow.key]?.value as? Double ?? 0
                    },
                    set: { newValue in
                        self.package.prefs[preferenceRow.key] = .init(newValue)
                    }
                ))
            case "string":
                TextField(preferenceRow.title, text: Binding<String>(
                    get: {
                        self.package.prefs[preferenceRow.key]?.value as? String ?? ""
                    },
                    set: { newValue in
                        self.package.prefs[preferenceRow.key] = .init(newValue)
                    }
                ))
            case "color":
                ColorPicker(preferenceRow.title, selection: Binding<Color>(
                    get: {
                        if let color = self.package.prefs[preferenceRow.key]?.value as? Color {
                            return color
                        } else if let colorDict = self.package.prefs[preferenceRow.key]?.value as? [String: Any] {
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: colorDict, options: []) else { return .black }
                            let decoder = JSONDecoder()
                            guard let col = try? decoder.decode(Color.self, from: jsonData) else { return .black }
                            return col
                        }
                        return .black
                    },
                    set: { newValue in
//                        let encoder = JSONEncoder()
//                        guard let jsonData = try? encoder.encode(newValue) else { return }
//                        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
                        self.package.prefs[preferenceRow.key] = .init(newValue)
                    }
                ))
            default:
                Text("Unsupported type: \(type)")
            }
        }
    }
}

