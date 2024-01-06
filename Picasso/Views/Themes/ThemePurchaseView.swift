//
//  ThemePurchaseView.swift
//  Picasso
//
//  Created by sourcelocation on 01/12/2023.
//

import SwiftUI
import CachedAsyncImage
import NavigationBackport
import WebKit

struct IconGridView: View {
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    @State private var previewThemeI: Int = 0
    
    private let suffledThemes: [SourcedRepoFetcher.RepoTheme]
    let themes: [SourcedRepoFetcher.RepoTheme]
    var appIDsForEachI: [String] = []
    
    /// theme i; app-id: image
    @State var iconPreviews: [[String: UIImage?]] = []
    
    init(themes: [SourcedRepoFetcher.RepoTheme]) {
        self.themes = themes
        self.suffledThemes = themes.shuffled()
        
        for _ in 0...64 {
            appIDsForEachI.append(["com.apple.mobilephone", "com.apple.mobilesafari", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.AppStore", "com.apple.Preferences", "com.apple.Music", "com.apple.calculator"].randomElement()!)
        }
    }
    
    var body: some View {
//        LazyHGrid(rows: [
//            GridItem(.adaptive(minimum: 70), spacing: 0)
//        ], spacing: 0, content: {
        
        HStack {
            ForEach(0...7, id: \.self) { i1 in
                VStack {
                    ForEach(0...7, id: \.self) { i2 in
                        let themeToPreview = suffledThemes[previewThemeI]
                        if !iconPreviews.isEmpty {
                            if let icon = iconPreviews[previewThemeI][appIDsForEachI[i1 * 8 + i2]], let icon {
                                Image(uiImage: icon)
                                    .resizable()
                                    .frame(width: 90, height: 90)
                                    .cornerRadius(22)
                                    .padding(5)
                                    .animation(.linear, value: icon)
                            } else {
                                Rectangle()
                                    .frame(width: 90, height: 90)
                                    .background(.tertiary)
                                    .cornerRadius(22)
                                    .padding(5)
                            }
                        }
                        
                        
//                        Image(systemName: "doc")
//                            .frame(width: 60, height: 60)
//                            .background(.tertiary)
//                            .cornerRadius(15)
//                            .padding(5)
                    }
                }
            }
        }
        .onReceive(timer) { input in
            withAnimation {
                previewThemeI += 1
                
                if previewThemeI + 1 > themes.count {
                    previewThemeI = 0
                }
            }
        }
        .onAppear {
            
            
            for (themeI,theme) in themes.enumerated() {
                let appIDs = ["com.apple.mobilephone", "com.apple.mobilesafari", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.AppStore", "com.apple.Preferences", "com.apple.Music", "com.apple.calculator"]
                for (appIDI, appID) in appIDs.enumerated() {
                    DispatchQueue.global().async {
                        do {
                            let data = try Data(contentsOf: SourcedRepoFetcher.shared.previewIconURL(appID: appID, inTheme: theme)! )
                            let image = UIImage(data: data)
                            DispatchQueue.main.async {
                                if themeI >= iconPreviews.count {
                                    iconPreviews.append([:])
                                }
                                iconPreviews[themeI][appID] = image
                            }
                        } catch {
                            print("error loading icon preview for \(theme.name) \(appIDI)")
                        }
                    }
                }
            }
        }
    }
}


struct ThemePurchaseView: View {
    @State var type = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.dismiss) var dismiss
    
    @State var loading: Bool = false
    @State var paymentURL: URL?
    
    @State var hasDiscount: Bool = false
    
    let themes: [SourcedRepoFetcher.RepoTheme]
    
    var body: some View {
        ZStack {
            IconGridView(themes: themes)
                .rotationEffect(.init(degrees: -30.0))
                .ignoresSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
                .mask(LinearGradient(gradient: Gradient(colors: [.clear, Color(.systemBackground).opacity(0.3)]), startPoint: .bottom, endPoint: .top))

            VStack {
                ThemePurchaseDetailView(type: $type)
                    .padding(.top, 70)
                    .padding(.bottom)
                Text("\(themes.count) beautifully-crafted icon packs, now available for your jailed devices.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ScrollView {
                    Text("Scroll horizontally to view more")
                        .padding(.top, 10)
                        .padding(.horizontal, 32)
//                        .foregroundStyle(.secondary)
                    LazyVStack {
                        ForEach(themes, id: \.name) { theme in
                            ThemePreviewCardView(theme: theme)
                                .tag(theme.name)
                                .padding(.bottom, 20)
                                .padding(.horizontal)
                        }
                    }
                }
                Button(action: {
                    Haptic.shared.play(.soft)
                    print("money money cha ching")
                    loading = true
                    
                    purchaseButtonPressed()
                }, label: {
                    if !loading {
                        Text("$\(hasDiscount ? "4.45" : "5.95") - One-Time \(hasDiscount ? "(Discount)" : "")")
                            .padding(2)
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                            .foregroundColor(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                    } else {
                        ProgressView()
                    }
                })
                .padding(.bottom, 80)
                .padding(.horizontal, 20)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .opacity(loading ? 0.5 : 1)
            }
            .ignoresSafeArea(.all)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
        .background(Color(UIColor.systemBackground).opacity(0.95))
        .toolbar {
            Button(action: {
                dismiss()
            }, label: {
                CloseButton()
            })
        }
        .sheet(isPresented: .init(get: { paymentURL != nil }, set: { paymentURL = ($0 ? paymentURL : nil) }), onDismiss: {
            Task {
                let purchases = try await SourcedRepoFetcher.shared.purchases()
                if purchases.contains("picasso-themes") {
                    SourcedRepoFetcher.shared.accountPurchases.append("picasso-themes")
                    UIApplication.shared.alert(title: "Picasso Themes was added to your account", body: "Thank you for the purchase!")
                    dismiss()
                }
                
                loading = false
            }
        }) {
            if let paymentURL {
                FancyWebView(url: paymentURL, isSheet: true)
            }
        }
        .onAppear {
            Task {
                let purchases = try await SourcedRepoFetcher.shared.purchases()
                
                hasDiscount = purchases.contains("picasso")
            }
        }
    }
    
    func purchaseButtonPressed() {
        Task {
            do {
                let url = try await SourcedRepoFetcher.shared.requestCheckoutSession(packageShortName: "picasso-themes")
                print(url)
                paymentURL = url
            } catch {
                loading = false
                await UIApplication.shared.alert(body: "\(error.localizedDescription)")
            }
        }
    }
}


struct ThemePreviewCardView: View {
    public var theme: SourcedRepoFetcher.RepoTheme
    var body: some View {
        ZStack {
//            CachedAsyncImage(url: URL(string: theme.pictureURL)!) { image in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 250, height: 150)
//                    .cornerRadius(16)
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
//            } placeholder: {
//                ZStack(alignment: .center) {
//                    Rectangle()
//                        .background(.thickMaterial)
//                        .frame(width: 250, height: 150)
//                    ProgressView()
//                        .font(.title3)
//                }
//                .cornerRadius(16)
//                .clipShape(RoundedRectangle(cornerRadius: 16))
//            }
//            .padding()
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    ForEach(0..<9) { i in
                        if i < 8 {
                            CachedAsyncImage(url: SourcedRepoFetcher.shared.previewIconURL(appID: ["com.apple.mobilephone", "com.apple.mobilesafari", "com.apple.mobileslideshow", "com.apple.camera", "com.apple.AppStore", "com.apple.Preferences", "com.apple.Music", "com.apple.calculator"][i], inTheme: theme)) { imageView in
                                imageView
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .cornerRadius(10)
                            } placeholder: {
                                Rectangle()
                                    .frame(width: 48, height: 48)
                                    .cornerRadius(10)
                                    .background(.tertiary)
                            }
                            .padding(.leading, i == 0 ? 20 : 0)
                        } else {
                            ZStack {
                                Rectangle()
                                    .frame(width: 48, height: 48)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                                    .opacity(0.2)
                                Text("+\(theme.iconCount - 8)")
                                    .foregroundStyle(.white)
                            }
                            .padding(.trailing)
                        }
                    }
                }
                .padding(.bottom, 48)
                .padding(.top, 16)
            }
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Text(theme.name)
                        .font(.headline)
                    Text(" · \(theme.iconCount)")
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    Text("\(theme.author)")
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
                .padding(.horizontal)
                .allowsHitTesting(false)
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

struct ThemePreviewCardView_Previews: PreviewProvider {
    static var previews: some View {
        return ThemePreviewCardView(theme: .init(name: "Rogue Pure Black", author: "sourcelocation", shortName: "rogue-pure-black", iconCount: 504, fileName: "rogue-pure-black.zip", packName: "themes"))
    }
}

struct ThemePurchasePreviewWrapperView: View {
    @State var themes: [SourcedRepoFetcher.RepoTheme] = []
    @State var showingModal: Bool = false
    @State var text: String = "loading themes"
    var body: some View {
        Text(text)
            .sheet(isPresented: $showingModal) {
                ThemePurchaseView(themes: themes)
            }
            .task(priority: .userInitiated) {
                do {
                    themes = try await SourcedRepoFetcher().getThemes()
                    showingModal = true
                } catch {
                    text += "\n\n\(error)"
                }
            }
    }
}

struct ThemePurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        ThemePurchasePreviewWrapperView()
    }
}
