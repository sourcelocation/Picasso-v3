//
//  ContentView.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-04.
//

import SwiftUI

enum SelectableTab: String, CaseIterable {
    case home = "Home"
    case unifiedTweaks = "Tweaks"
    case explore = "Explore"
    case installed = "Installed"
    case themes = "Themes"
    case create = "Create"
    case toolbox = "Toolbox"

    var icon: String {
        switch self {
        case .home: return "house"
        case .unifiedTweaks, .toolbox: return "wrench"
        case .explore: return "safari"
        case .installed: return "arrow.down.square"
        case .themes: return "paintbrush"
        case .create: return "wrench.and.screwdriver.fill"
        }
    }
}

struct RootView: View {
    @AppStorage("creatorMode") private var creatorMode: Bool = false
    @AppStorage("unifiedTweaks") private var unifiedTweaks: Bool = false
    @State var selectedTab: SelectableTab = .home
    @State var allowedTabs: [SelectableTab] = []
    
    func computeAllowedTabs(_ t: Bool) {
        allowedTabs = [
            .home,
            unifiedTweaks ? .unifiedTweaks : .explore,
            unifiedTweaks ? nil : .installed,
            .themes,
            creatorMode && !unifiedTweaks ? .create : nil,
            .toolbox
        ].compactMap {$0}
    }
    
    var body: some View {
        GeometryReader { proxy in
            let hasHomeIndicator = proxy.safeAreaInsets.bottom - 88 > 20
            ZStack {
                Group {
                    switch selectedTab {
                    case .home: HomeView(currentTab: $selectedTab)
                    case .unifiedTweaks: UnifiedTweaksView()
                    case .explore: ExploreViewWrapper()
                    case .installed: InstalledTweaksViewWrapper(currentTab: $selectedTab)
                    case .themes: ThemesView()
                    case .create: TweakEditorHomeWrapper()
                    case .toolbox: ToolsView()
                    }
                }
                TabBar(allowedTabs: $allowedTabs, selectedTab: $selectedTab)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 88) }
            .onAppear { computeAllowedTabs(true) }
            .onChange(of: creatorMode, perform: computeAllowedTabs)
            .onChange(of: unifiedTweaks, perform: computeAllowedTabs)
        }
    }
}


struct TabPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TabBar: View {
    @Binding var allowedTabs: [SelectableTab]
    @Binding var selectedTab: SelectableTab
    @State var tabItemWidth: CGFloat = 0
    @State var color: Color = .accentColor
    
    var body: some View {
        GeometryReader { proxy in
            let hasHomeIndicator = proxy.safeAreaInsets.bottom - 88 > 20
            
            HStack {
                ForEach(allowedTabs, id:\.hashValue) { item in
                    Button {
                        if UIAccessibility.isReduceMotionEnabled {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = item
                                Haptic.shared.play(.soft)
                            }
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = item
                                Haptic.shared.play(.soft)
                            }
                        }
                    } label: {
                        VStack(spacing: 0) {
                            Image(systemName: item.icon)
                                .symbolVariant(.fill)
                                .font(.body.bold())
                                .frame(width: 44, height: 29)
//                                .foregroundColor(selectedTab == item ? .accentColor: .secondary)
                            Text(item.rawValue)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(selectedTab == item ? .primary : .secondary)
                    .blendMode(selectedTab == item ? .overlay : .normal)
                    .overlay(
                        GeometryReader { proxy in
                            Color.clear.preference(key: TabPreferenceKey.self, value: proxy.size.width)
                        }
                    )
                    .onPreferenceChange(TabPreferenceKey.self) { value in
                        tabItemWidth = value
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 14)
            
            .frame(height: hasHomeIndicator ? 88 : 62, alignment: .top)
            .background(Material.bar, in: RoundedRectangle(cornerRadius: hasHomeIndicator ? 34 : 0, style: .continuous))
            .background(
                HStack {
                    let idx = (allowedTabs.firstIndex(of: selectedTab) ?? 0)
                    let left = allowedTabs.count == 0 ? 1 : allowedTabs.distance(from: 0, to: idx)
                    let right =  allowedTabs.count == 0 ? 1 : allowedTabs.distance(from: idx, to: allowedTabs.count - 1)
                    
                    ForEach(Array(0...left).filter { $0 != 0 }, id: \.self) { i in Spacer() }
                    Circle().fill(color).frame(width: tabItemWidth)
                    ForEach(Array(0...right).filter { $0 != 0 }, id: \.self) { i in Spacer() }
                }        .padding(.horizontal, 8)
            )
            .overlay(
                HStack {
                    let idx = (allowedTabs.firstIndex(of: selectedTab) ?? 0)
                    let left = allowedTabs.count == 0 ? 1 : allowedTabs.distance(from: 0, to: idx)
                    let right =  allowedTabs.count == 0 ? 1 : allowedTabs.distance(from: idx, to: allowedTabs.count - 1)
                    let t_width = allowedTabs.count > 5 ? 16 : (allowedTabs.count > 4 ? 22 : 28)
                    
                    
                    ForEach(Array(0...left).filter { $0 != 0 }, id: \.self) { i in Spacer() }
                    Rectangle()
                        .fill(color)
                        .frame(width: CGFloat(t_width), height: 5)
                        .cornerRadius(3)
                        .frame(width: tabItemWidth)
                        .frame(maxHeight: .infinity, alignment: .top)
                    ForEach(Array(0...right).filter { $0 != 0 }, id: \.self) { i in Spacer() }
                }        .padding(.horizontal, 8)

            )
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
    }
}
