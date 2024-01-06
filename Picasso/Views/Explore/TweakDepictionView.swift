//
//  TweakDepictionView.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-05.
//

import SwiftUI
import CachedAsyncImage

struct TweakDepictionView: View {
    
    @Binding var package: RepoPackage
    @StateObject var tweakManager = TweakManager.shared
    
    var currentAccentColor: Color {
        return Color(uiColor: ((cs == .light ? palette.DarkMuted?.uiColor : palette.Vibrant?.uiColor) ?? UIColor(named: "AccentColor"))!)
    }
    @Environment(\.colorScheme) var cs
    @State var palette: Palette = .init()
    
    @AppStorage("favouriteList") var favouriteList: [String] = []
    
    @State var isHearted: Bool = false
    
    var body: some View {
        ZStack {
            currentAccentColor
                .ignoresSafeArea(.all)
                .opacity(0.07)
            ScrollView {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading, spacing: 24) {
                                CachedAsyncImage(url: package.iconURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(20)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 80, height: 80)
                                        .background(.secondary)
                                        .cornerRadius(20)
                                }
                                .padding(.top, -5)
                                VStack(alignment: .leading) {
                                    Text(package.name)
                                        .font(.largeTitle.weight(.bold))
                                    Text(package.author) // package.description.wrappedValue)
                                        .font(.headline.weight(.regular))
//                                    Label("repo name", systemImage: "shippingbox") // package.description.wrappedValue)
//                                        .font(.callout)
//                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }
                        Button(action: {
                            Haptic.shared.play(.soft)
                            func actuallyInstall() {
                                Task {
                                    do {
                                        try await tweakManager.installPackage(package)
                                        Haptic.shared.notify(.success)
                                        DispatchQueue.main.async {
                                            UIApplication.shared.alert(title: "Success", body: "Tweak has been successfully installed.")
                                        }
                                    } catch {
                                        Haptic.shared.notify(.error)
                                        DispatchQueue.main.async {
                                            UIApplication.shared.alert(body: "\(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                            
                            
                            
                            if let myVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let myBuild = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String)?.components(separatedBy: " ").last {
                                if let version = package.minPicassoVersion, let build = package.minPicassoBuild {
                                    if myVersion.compare(version, options: .numeric) == .orderedAscending || myBuild.compare(build, options: .numeric) == .orderedAscending {
                                        UIApplication.shared.confirmAlert(title: "Incompatible Picasso Version", body: "This tweak was designed for Picasso \(version) (\(build)). You are currently running OpenPicasso \(myVersion) (\(myBuild)). Would you like to continue anyway?", confirmTitle: "Continue", cancelTitle: "Cancel", onOK: {
                                            actuallyInstall()
                                        }, noCancel: false)
                                    } else {
                                        actuallyInstall()
                                    }
                                } else {
                                    actuallyInstall()
                                }
                            } else {
                                actuallyInstall()
                            }
                        }, label: {
                            Text("Get")
                                .bold()
                                .foregroundColor(currentAccentColor)
                                .padding(6)
                                .padding(.horizontal, 8)
                                .background(currentAccentColor.opacity(0.2))
                                .cornerRadius(50)
                        })
                        .padding([.bottom], 8)
                        HStack {
                            Group {
                                VStack(spacing: 4) {
                                    Label("6.9", systemImage: "star")
                                        .font(.system(.title, design: .rounded).weight(.regular))
                                    Text("Reviews")
                                }
                                Divider()
                                Button(action: {
                                    if let foo = favouriteList.firstIndex(where: {$0 == package.bundleID}) {
                                        favouriteList.remove(at: foo)
                                    } else {
                                       // item could not be found
                                        favouriteList.append(package.bundleID)
                                    }
                                    updateFavStatus()
                                    if isHearted {
                                        Haptic.shared.notify(.success)
                                    } else {
                                        Haptic.shared.notify(.error)
                                    }
                                }, label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: isHearted ? "heart.fill" : "heart")
                                            .font(.system(.title).weight(.regular))
                                        Text(isHearted ? "Remove from Wishlist" : "Add to Wishlist")
                                    }
                                })
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .padding([.horizontal], 0.1)
                        .cornerRadius(CGFloat(16.0), antialiased: true)
                        
                        Text("Description")
                            .font(.title2.weight(.bold))
                            .padding([.top], 10)
                            .padding([.bottom], 3)
                        Text(package.description ?? "No description provided by author.")
                            .font(.body)
                    }
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                Spacer()
            }
            //.background(.ultraThickMaterial)
        }
        .task(priority: .background) {
            let imageData = await getImageData()
            self.palette = Vibrant.from(UIImage(data: imageData) ?? UIImage(named: "AppIcon-preview")!).getPalette()
        }
        .task(priority: .userInitiated) {
            updateFavStatus()
        }
        
        .navigationBarTitleDisplayMode(.inline)
        .tint(currentAccentColor)
        .animation(.easeInOut(duration: 0.25), value: currentAccentColor)
    }
    
    func getImageData() async -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: package.iconURL)
            return data
        } catch {
            return (UIImage(named: "AppIcon-preview")?.pngData())!
        }
    }
    
    func updateFavStatus() {
        isHearted = favouriteList.contains(package.bundleID)
    }
}


//struct TweakDepictionView_Previews: PreviewProvider {
//    static var previews: some View {
//        TweakDepictionView(package: )
//    }
//}

struct ExploreViewAndByExtensionTweakDepictionView_Previews /* is this what god wanted */ : PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
