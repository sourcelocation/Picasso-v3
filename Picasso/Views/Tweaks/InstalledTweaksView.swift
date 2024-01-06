//
//  TweaksView.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-04.
//

import SwiftUI
import CachedAsyncImage
import NavigationBackport
import SwiftUIBackports

struct InstalledTweaksViewWrapper: View {
    @Binding var currentTab: SelectableTab
    var body: some View {
        Navigator {
            InstalledTweaksView(currentTab: $currentTab)
                .navigationTitle("Installed Tweaks")
        }
    }
}

struct InstalledTweaksView: View {
    
    @StateObject var tweakManager = TweakManager.shared
    
    @AppStorage("creatorMode") private var creatorMode: Bool = false
    
    @Binding var currentTab: SelectableTab
    
    @State private var searchText: String = ""
    
    @State private var currentList: [LocalPackage] = TweakManager.shared.installedPackages
    
    public var createTabTag: SelectableTab = .create
        
    var body: some View {
            VStack {
                if tweakManager.installedPackages.isEmpty {
                    ZStack {
                        ScrollView {}
                        VStack {
                            ZStack(alignment: .center) {
                                Image(systemName: "app.dashed")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 80).weight(.light))
                                    .imageScale(.medium)
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 40).weight(.regular))
                                    .imageScale(.small)
                            }
                            Text("No tweaks installed yet.\n Would you like to browse them?")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 64)
                                .multilineTextAlignment(.center)
                                .padding([.top], 2)
                                .padding([.bottom])
                            
                            HStack {
                                Button(action: {
                                    currentTab = .explore
                                }, label: {
                                    Text("Explore")
                                        .foregroundColor(Color(UIColor.systemBackground))
                                })
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                if creatorMode {
                                    Button(action: {
                                        currentTab = createTabTag
                                    }, label: {
                                        Text("Create")
                                    })
                                    .buttonStyle(.bordered)
                                    .controlSize(.large)
                                    .tint(.accentColor)
                                }
                            }
                        }
                    }
                } else {
                    List {
                        Section(footer: Label("To remove tweaks, swipe them to the left.\nYou may export a tweak by holding on it.", systemImage: "info.circle")) {
                            ForEach(currentList) { package in
                                //                            if package.prefsConfig.preferences.wrappedValue.isEmpty {
                                //                                Row(package: package)
                                //                            } else {
                                NavigationLink {
                                    TweakPreferencesView(package: package)
                                } label: {
                                    Row(package: package)
                                }
                                .contextMenu {
                                    Button(action: {
                                        // present spinner
                                        UIApplication.shared.progressAlert(title: "Exporting \(package.info.name)...")
                                        Task {
                                            do {
                                                // do cool thing
                                                let exportedPackage: URL = try await tweakManager.exportPackage(package)
                                                // dismiss spinner
                                                UIApplication.shared.dismissAlert(animated: true)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // just in case it doesnt dismiss in time
                                                    // show sharesheet
                                                    shareURL(exportedPackage)
                                                }
                                            } catch {
                                                // dismiss spinner
                                                UIApplication.shared.dismissAlert(animated: true)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // just in case it doesnt dismiss in time
                                                    // show error
                                                    UIApplication.shared.alert(body: error.localizedDescription)
                                                }
                                            }
                                        }
                                    }, label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    })
                                }
                            }
                            .onDelete(perform: delete)
                            .listRowInsets(.init(top: 10, leading: 12, bottom: 10, trailing: 20))
                        }
                    }
                    .refreshable {
                        Haptic.shared.play(.light)
                        await updatePackagesWithSuperCoolDelay()
                        Haptic.shared.play(.medium)
                    }
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .onChange(of: searchText) {text in
                        if text.isEmpty {
                            currentList = tweakManager.installedPackages
                        } else {
                            currentList = tweakManager.installedPackages.filter { $0.info.name.localizedCaseInsensitiveContains(text) }
                        }
                    }
                    .onAppear {
                        currentList = tweakManager.installedPackages
                    }
                }
            }
    }
    
    
    
    func updatePackagesWithSuperCoolDelay() async {
        tweakManager.updateInstalledPackages()
    }
    
    func delete(at offsets: IndexSet) {
        func delete(force: Bool) {
            guard let first = offsets.first else { return }
            do {
                let package = tweakManager.installedPackages[first]
                try tweakManager.removePackage(package, force: force)
            } catch {
                UIApplication.shared.confirmAlert(title: "Error", body: "\(error.localizedDescription)", confirmTitle: "Force delete (not safe)", cancelTitle: "Cancel", onOK: {
                    delete(force: true)
                }, noCancel: false)
            }
        }
        delete(force: false)
    }
    
    struct Row: View {
        @ObservedObject var package: LocalPackage
        var body: some View {
            HStack(spacing: 16) {
                CachedAsyncImage(url: package.info.iconURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .cornerRadius(12)
                } placeholder: {
                    if package.info.iconURL == nil {
                        DefaultTweakIcon()
                            .frame(width: 50, height: 50)
                            .cornerRadius(12)
                    } else {
                        ZStack(alignment: .center) {
                            Rectangle()
                                .background(.thinMaterial)
                                .frame(width: 50, height: 50)
                            ProgressView()
                                .font(.title3)
                        }
                        .cornerRadius(12)
                        .frame(width: 50, height: 50)
                    }
                }
                VStack(alignment: .leading) {
                    Text(package.info.name)
                        .font(.headline)
                    HStack {
                        Text("\(package.info.version) • \(package.info.author)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct DefaultTweakIcon: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.accentColor)
                .opacity(0.3)
                .brightness(-0.2)
                .frame(width: 50, height: 50)
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.title3)
                .imageScale(.large)
                .foregroundColor(.accentColor)
        }
        .frame(width: 50, height: 50)
    }
}

struct InstalledTweaksView_Previews: PreviewProvider {
    static var previews: some View {
        InstalledTweaksViewPreviewWrapper()
    }
}


struct InstalledTweaksViewPreviewWrapper : View {
    @State private var value: SelectableTab = .installed
    
    var body: some View {
        InstalledTweaksView(currentTab: $value)
    }
}

struct TweakIconPreview: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .center) {
            DefaultTweakIcon()
                .frame(width: 50, height: 50)
        }
    }
}
