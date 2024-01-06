//
//  UnifiedTweaksView.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-09-09.
//

import SwiftUI
import NavigationBackport

struct UnifiedTweaksView: View {
    @State var currentTab: SelectableTab = .explore
    var body: some View {
        Navigator {
            VStack {
                Picker("", selection: $currentTab, content: {
                    Label("Explore", systemImage: "safari")
                        .tag(SelectableTab.explore)
                    Label("Installed", systemImage: "arrow.down.square")
                        .tag(SelectableTab.installed)
                    Label("Create", systemImage: "wrench.and.screwdriver")
                        .tag(SelectableTab.create)
                })
                    .padding(.horizontal)
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .onChange(of: currentTab) {_ in
                        Haptic.shared.play(.soft)
                    }
                
                switch currentTab {
                case .explore:
                    ExploreView()
                case .installed:
                    InstalledTweaksView(currentTab: $currentTab, createTabTag: .unifiedTweaks)
                case .create:
                    TweakEditorHome()
                default:
                    Text("WTF?!")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(unexpectedErrorString)
                }
            }
            .navigationTitle("Tweaks")
        }
    }
}

//#Preview {
//    UnifiedTweaksView()
//}
