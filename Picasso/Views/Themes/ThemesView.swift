//
//  ThemesView.swift
//  Picasso
//
//  Created by sourcelocation on 23/08/2023.
//

import SwiftUI
import CachedAsyncImage
import NavigationBackport

// TODO: Add button to open purchase modal
struct ThemesView: View {
    
    @StateObject var themeManager = ThemeManager.shared
    
    @State var showingFilePicker = false
    @State var showingPurchasesModal = false
    
    @State var sourcedRepoThemes: [SourcedRepoFetcher.RepoTheme]?
    
    @AppStorage("shownAnalyticsAlert") var shownAnalyticsAlert = false
    
    @State var showingApplyView: Bool = false
    @State var showingSettingsView: Bool = false
    @State var shouldRevert: Bool = false
    
    init() { }
    
    @ViewBuilder
    var importedSection: some View {
        Section {
            Text("Imported")
                .multilineTextAlignment(.leading)
                .font(.title3.weight(.semibold))
                .padding(.leading, 10)
            
            ForEach(themeManager.themes) { theme in
                LocalThemeView(theme: theme)
            }
        }
        .padding(.horizontal, 14)
    }
    
    @ViewBuilder
    var sourcedRepoThemesSection: some View {
        if let sourcedRepoThemes {
            Section {
                Text("Picasso Themes")
                    .multilineTextAlignment(.leading)
                    .font(.title3.weight(.semibold))
                    .padding(.leading, 10)
                    .padding(.top, 20)
                
                let importedThemeNames = themeManager.themes.map { $0.name }
                let nonDownloadedThemes = Array(sourcedRepoThemes.filter { !importedThemeNames.contains($0.name) })
                ForEach(nonDownloadedThemes, id: \.shortName) { sourcedRepoTheme in
                    SourcedRepoThemeView(theme: sourcedRepoTheme, getButtonTapped: {
                        if SourcedRepoFetcher.shared.accountPurchases.contains("picasso-themes") {
                            if !shownAnalyticsAlert {
                                UIApplication.shared.alert(title: "Usage analytics", body: "We need icon theme usage data to determine which themes were used more, and which were used less for a fair revenue split among designers. You may opt-out in settings.")
                                UserDefaults.standard.set(true, forKey: "shownAnalyticsAlert")
                            } else {
                                UIApplication.shared.alert(title: "Downloading...", body: "This should take a minute or less. File size is usually 50MB", withButton: false)
                                Task {
                                    do {
                                        try await downloadTheme(theme: sourcedRepoTheme)
                                        UIApplication.shared.change(title: "Download finished", body: "You may now apply the theme", addCancelWithTitle: "OK")
                                    } catch {
                                        UIApplication.shared.change(title: "Error", body: "\(error.localizedDescription)", addCancelWithTitle: "OK")
                                    }
                                }
                            }
                        } else {
                            showingPurchasesModal = true
                            
                        }
                    })
                }
                
                VStack {}
                    .padding(.bottom, 80)
            }
            .padding(.horizontal, 14)
        }
    }
    
    @ViewBuilder
    var bottomBar: some View {
        
        HStack {
            Button {
                apply(revert: true)
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .tint(.red)
            Button {
                apply(revert: false)
            } label: {
                Text("Apply")
                    .frame(maxWidth: .infinity)
            }
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .tint(.accentColor)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .padding()
    }
    
    @ViewBuilder
    var toolbarStack: some View {
        HStack {
            Button {
                showingSettingsView = true
            } label: {
                Image(systemName: "gear")
            }
            .sheet(isPresented: $showingSettingsView, content: {
                ThemingSettingsView()
            })
            Button {
                showingFilePicker = true
            } label: {
                Image(systemName: "square.and.arrow.down")
            }
        }
    }
    
    
    var body: some View {
        GeometryReader { proxy in
            let hasHomeIndicator = proxy.safeAreaInsets.bottom - 88 > 20
            Navigator {
                ZStack {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            importedSection
                            sourcedRepoThemesSection
                        }
                        .sheet(isPresented: $showingPurchasesModal) {
                            ThemePurchaseView(themes: sourcedRepoThemes!)
                        }
                    }
                    VStack {
                        Spacer()
                        bottomBar
//                            .padding(.bottom, hasHomeIndicator ? 48 : 22) // TODO: Test on non-notched devices
                            .modifier(AutoPad())
                    }
                }
                .navigationTitle("Themes")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        toolbarStack
                    }
                }
                .sheet(isPresented: $showingFilePicker) {
                    DocumentPicker(types: [ .folder ], allowsMultipleSelection: false) { urls in
                        for url in urls {
                            defer { url.stopAccessingSecurityScopedResource() }
                            do {
                                try themeManager.importTheme(iconBundle: url)
                            } catch {
                                UIApplication.shared.alert(body: error.localizedDescription)
                            }
                        }
                        themeManager.updateThemes()
                    }
                }
                .sheet(isPresented: $showingApplyView) {
                    ThemeApplyProgressView(revert: shouldRevert)
                }
                .onAppear {
                    themeManager.updateThemes()
                    
                    Task {
                        let themes = try await SourcedRepoFetcher().getThemes()
                        self.sourcedRepoThemes = themes.shuffled()
                    }
                }
            }
        }
    }
    
    func downloadTheme(theme: SourcedRepoFetcher.RepoTheme) async throws {
        try await themeManager.downloadSourcedRepoTheme(repoTheme: theme)
        themeManager.updateThemes()
    }
    
    func apply(revert: Bool) {
        shouldRevert = revert
        showingApplyView = true
    }
    
    struct ThemeIconPreviewView: View {
        var url: URL?
        var image: UIImage?
        
        var body: some View {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 28, height: 28)
                    .cornerRadius(5)
                    .padding(2)
            } else if let url {
                CachedAsyncImage(url: url) { imageView in
                    imageView
                        .resizable()
                        .frame(width: 28, height: 28)
                        .cornerRadius(5)
                } placeholder: {
                    Rectangle()
                        .frame(width: 28, height: 28)
                        .cornerRadius(5)
                        .background(.tertiary)
                }
                
            }
        }
    }
    
    struct LocalThemeView: View {
        
        @Environment(\.colorScheme) var colorScheme
        @StateObject var theme: IconTheme
        
        @State var icons: [UIImage?] = []
        
        var body: some View {
            VStack(alignment: .leading) {
                VStack {
                    if icons.count >= 8 {
                        VStack {
                            HStack {
                                ForEach(icons[0...3], id: \.self) {
                                    if $0 != nil {
                                        ThemeIconPreviewView(image: $0!)
                                            .padding(2)
                                    }
                                }
                            }
                            HStack {
                                ForEach(icons[4...7], id: \.self) {
                                    if $0 != nil {
                                        ThemeIconPreviewView(image: $0!)
                                            .padding(2)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    } else {
                        Text("Could not generate preview for this theme. Is it even a theme?")
                            .padding(10)
                            .background(Color.yellow.opacity(0.20))
                            .cornerRadius(10)
                    }
                    HStack {
                        HStack(spacing: 0) {
                            Text(theme.name)
                                .font(.headline)
                            Text(" · \(theme.iconCount)")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            theme.isSelected.toggle()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .aspectRatio(contentMode: .fit)
                                .symbolRenderingMode(theme.isSelected ? .monochrome : .hierarchical)
                                .foregroundColor(theme.isSelected ? .accentColor : .secondary)
                        }
                    }
                }
                .onAppear {
                    icons = ThemeManager.shared.getAppIcons(for: ["com.apple.mobilephone", "com.apple.mobilesafari", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.AppStore", "com.apple.Preferences", "com.apple.Music", "com.apple.calculator"], theme: theme)
                }
            }
            .padding(10)
            .padding(.horizontal, 4)
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemGroupedBackground))
            .cornerRadius(12)
            .contextMenu {
                Button {
                    do {
                        try ThemeManager.shared.deleteTheme(theme: theme)
                    } catch {
                        UIApplication.shared.alert(body: "Unable to remove theme. \(error.localizedDescription)")
                    }
                } label: {
                    Label("Remove from imported", systemImage: "trash")
                }
            }
            .onTapGesture {
                theme.isSelected.toggle()
            }
        }
    }
    
    struct SourcedRepoThemeView: View {
        
        var getButtonTapped: () -> ()
        
        var theme: SourcedRepoFetcher.RepoTheme
        var urls: [URL]
        
        @Environment(\.colorScheme) var colorScheme
        
        init(theme: SourcedRepoFetcher.RepoTheme, getButtonTapped: @escaping () -> ()) {
            self.theme = theme
            self.getButtonTapped = getButtonTapped
            let appIDs = ["com.apple.mobilephone", "com.apple.mobilesafari", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.AppStore", "com.apple.Preferences", "com.apple.Music", "com.apple.calculator"]
            
            urls = appIDs.compactMap { SourcedRepoFetcher.shared.previewIconURL(appID: $0, inTheme: theme) }
            print(urls)
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                VStack {
                    VStack {
                        if urls.count >= 8 {
                            HStack {
                                ForEach(urls[0...3], id: \.absoluteString) {
                                    ThemeIconPreviewView(url: $0)
                                        .padding(4)
                                }
                            }
                            HStack {
                                ForEach(urls[4...7], id: \.absoluteString) {
                                    ThemeIconPreviewView(url: $0)
                                        .padding(4)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    HStack {
                        HStack(spacing: 0) {
                            Text(theme.name)
                                .font(.headline)
                            Text(" · \(theme.iconCount)")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            getButtonTapped()
                        } label: {
                            Label(title: { Text("Download")}, icon: { Image(systemName: "arrow.down")})
                        }
                        .buttonStyle(.bordered)
                        .tint(.accentColor)
                    }
                }
            }
            .padding(10)
            .padding(.horizontal, 4)
            .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemGroupedBackground))
            .cornerRadius(12)
        }
    }
}

struct ThemePurchaseDetailView: View {
    @Binding var type: Int
    var body: some View {
        if type == 1 {
            HStack {
                Text("Picasso Themes")
                    .padding(.top, 20)
                    .font(.largeTitle.weight(.heavy))
                Text("Pro")
                    .padding(.top, 20)
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [
                        Color(hex: "b5bdc8"),
                        Color(hex: "666672")
                    ]), startPoint: .top, endPoint: .bottom))
            }
        } else {
            Text("Picasso Themes")
                .padding(.top, 20)
                .font(.largeTitle.weight(.heavy))
                .foregroundStyle(.tint)
        }
    }
}

struct ThemePreview: Identifiable {
    public let id = UUID()
    var name: String
    var pictureURL: String
}


struct BruhView: View {
    var body: some View {
        Text("Bruh")
            .padding(1)
    }
}

struct ThemesView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesView()
    }
}
