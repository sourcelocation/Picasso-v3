////
////  SpringBoardElementPrefsView.swift
////  Picasso
////
////  Created by sourcelocation on 10/08/2023.
////
//
//import SwiftUI
//
//struct SpringBoardElementPrefsView: View {
//    @Binding var package: LocalPackage
//    
//    var body: some View {
//        let prefsConfig = self.package.prefsConfig
//        
//
//        Form {
//            ForEach(prefsConfig.preferences) { preferenceRow in
//                let type: String = preferenceRow.valueType
//                
//                switch type {
//                case "bool":
//                    Toggle(preferenceRow.key, isOn: Binding(
//                        get: {
//                            self.package.prefs[preferenceRow.key] as? Bool ?? false
//                        },
//                        set: { newValue in
//                            self.package.prefs[preferenceRow.key] = .init(newValue)
//                        }
//                    ))
//                default:
//                    Text("Unsupported type: \(type)")
//                }
//            }
//        }
//    }
//}
