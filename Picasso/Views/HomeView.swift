//
//  HomeView.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-04.
//

import SwiftUI
import NavigationBackport
import CachedAsyncImage

struct HomeView: View {
    
    @StateObject var sourcedRepoFetcher = SourcedRepoFetcher.shared
    @StateObject var tweakManager = TweakManager.shared
    
    @State var showingPrefs: Bool = false
    @State var showingAcc: Bool = false
    
    @State var updateInProgress: Bool = true
    
    @AppStorage("backgroundApplyingEnabled") var backgroundApplyingEnabled: Bool = false

    @State var cards: [Card] = []
    
    @Binding var currentTab: SelectableTab
    
    @State var randomChance: Int = 0
    
    struct Author: Identifiable {
        var id = UUID()
        var name: String
        var imageURL: String
        var link: String
    }
    
    let authors: [Author] = [
        .init(name: "sourcelocation", imageURL: "https://avatars.githubusercontent.com/u/52459150?v=4", link: "https://twitter.com/sourceloc"),
        .init(name: "BomberFish", imageURL: "https://bomberfish.ca/misc/pfps/bomberfish-picasso.png", link: "https://twitter.com/bomberfish77"),
        .init(name: "sneakyf1shy", imageURL: "https://pbs.twimg.com/profile_images/1390432487571136518/5WU8q3YM_400x400.jpg", link: "https://twitter.com/vishyfishy2"),
    ]
    
    @ViewBuilder
    var headerButtons: some View {
        HStack {
            Button("Apply", action: {
                Haptic.shared.play(.soft)
                UIApplication.shared.alert(title: "Applying...", body: "", withButton: false)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    do {
                        try TweakApplier.shared.applyTweaks()
                        Haptic.shared.notify(.success)
                        UIApplication.shared.dismissAlert(animated: true)
                        
                        if !UserDefaults.standard.bool(forKey: "dontShowSuccessAfterApply") {
                            UIApplication.shared.choiceAlert(title: "Success", body: "The tweaks were applied successfully", confirmTitle: "Don't show again", cancelTitle: "OK", yesAction: {
                                UserDefaults.standard.set(true, forKey: "dontShowSuccessAfterApply")
                            }, noAction: {})
                        }
                    } catch {
                        Haptic.shared.notify(.error)
                        UIApplication.shared.changeTitle("Error")
                        UIApplication.shared.changeBody("\(error.localizedDescription)")
                        currentUIAlertController?.addAction(.init(title: "OK", style: .cancel))
                    }
                }
            })
            .buttonStyle(.bordered)
            .tint(.accentColor)
            .controlSize(.large)
            
            Button("Respring", action: {
                respring()
            })
            .buttonStyle(.bordered)
            .tint(.accentColor)
            .controlSize(.large)
            .contextMenu {
                Button(action: {respring(type: .frontboard)}) {
                    Label("Restart Frontboard", systemImage: "apps.iphone")
                }
                Button(action: {respring(type: .backboard)}) {
                    Label("Restart Backboard", systemImage: "apps.iphone")
                }
                if ExploitKit.shared.isTrollStore {
                    Button(action: reboot) {
                        Label("Reboot (Userspace)", systemImage: "togglepower")
                    }
                }
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var header: some View {
        Section {
            VStack(spacing:20) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Image("AppIcon-preview")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 84)
                        Text("Welcome to OpenPicasso!")
                            .font(.title.bold())
                            .multilineTextAlignment(.leading)
                            .padding(.top, 8)
                        Text("Version \(appVersion) \nBy sourcelocation and BomberFish")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .padding(.top, 2)
                    }
                    Spacer()
                }
                headerButtons
            }
        }
        .padding()
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    var noTipsView: some View {
        HStack {
            Spacer()
            VStack {
                if randomChance == 69 {
                    Text("🫁")
                        .font(.largeTitle)
                        .padding(.top, -1)
                } else {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .imageScale(.large)
                        .padding(.top, 8)
                }
                Text("All good!")
                    .font(.title3.weight(.medium))
            }
            Spacer()
        }
        .padding(.top, 8)
        .foregroundColor(.secondary)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    var madeBySection: some View {
        Section {
            Text("Made by")
                .multilineTextAlignment(.leading)
                .font(.title3.weight(.semibold))
            
            VStack {
                ForEach(authors) { author in
                    Link(destination: URL(string: author.link)!) {
                        HStack {
                            CachedAsyncImage(url: URL(string: author.imageURL)!) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            } placeholder: {
                                Ellipse()
                                    .foregroundColor(.secondary)
                                    .frame(width: 32, height: 32)
                            }
                            Text(author.name)
                                .font(.headline)
//                                                .padding(.leading, 8)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
//    @ViewBuilder
//    var tipsSection: some View {
//        Section {
//            //Text(cards.isEmpty ? "Tips" : (cards.count == 1 ? "1 Tip" : "\(cards.count) Tips"))
//            Text("Tips")
//                .multilineTextAlignment(.leading)
//                .font(.title3.weight(.semibold))
//                .padding(.leading, 8)
//            if updateInProgress {
//                HStack {
//                    Spacer()
//                    ProgressView()
//                        .font(.largeTitle.weight(.black))
//                        .imageScale(.large)
//                        .controlSize(.large)
//                        .scaleEffect(0.8)
//                    Spacer()
//                }
//                .padding(.top, 40)
//            } else if (!updateInProgress && cards.isEmpty) {
//                noTipsView
//                    .padding(.vertical)
//            } else {
//                //                        ScrollView(.horizontal) {
//                LazyHStack {
//                    TabView {
//                        ForEach(cards) { card in
//                            TipCard(info: card)
//                                .padding(.horizontal, 16)
//                                .padding(.bottom, 55)
//                                .padding(.top, 2)
//                        }
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: 225)
//                    .tabViewStyle(PageTabViewStyle())
//                    .indexViewStyle(.page(backgroundDisplayMode: .always))
//                }
//                //                        }
//                .padding(.horizontal, -15.5)
//            }
//        }
//    }
    
    var body: some View {
        GeometryReader { geometry in
//            let hasHomeIndicator = geometry.safeAreaInsets.bottom - 88 > 20
            Navigator {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        header.padding(.horizontal, 15)
                        
                        // FIXME: formatting is fucked up
//                        tipsSection.frame(width: geometry.size.width, height: 225)
                        Section {
                            //Text(cards.isEmpty ? "Tips" : (cards.count == 1 ? "1 Tip" : "\(cards.count) Tips"))
                            Text("Tips")
                                .multilineTextAlignment(.leading)
                                .font(.title3.weight(.semibold))
                                .padding(.leading, 8)
                            if updateInProgress {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .font(.largeTitle.weight(.black))
                                        .imageScale(.large)
                                        .controlSize(.large)
                                        .scaleEffect(0.8)
                                    Spacer()
                                }
                                .padding(.top, 40)
                            } else if (!updateInProgress && cards.isEmpty) {
                                noTipsView
                                    .padding(.vertical)
                            } else {
                                //                        ScrollView(.horizontal) {
                                LazyHStack {
                                    TabView {
                                        ForEach(cards) { card in
                                            TipCard(info: card)
                                                .padding(.horizontal, 16)
                                                .padding(.bottom, 55)
                                                .padding(.top, 2)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 225)
                                    .tabViewStyle(PageTabViewStyle())
                                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                                }
                                //                        }
                                .padding(.horizontal, -15.5)
                            }
                        }
                        .frame(minWidth: UIScreen.main.bounds.width, maxWidth: geometry.size.width, minHeight: 225, maxHeight: 225)
                        
                        madeBySection
                            .padding(.horizontal, 15)
//                            .padding(.bottom, hasHomeIndicator ? 48 : 22) // TODO: Test on non-notched devices
                            .modifier(AutoPad())
                    }
                    .modifier(AutoPad())
//                    .padding(.bottom, hasHomeIndicator ? 48 : 22) // TODO: Test on non-notched devices
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 0)
                    .frame(
                        minWidth: UIScreen.main.bounds.width,
                        maxWidth: geometry.size.width,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack {
                                Button(action: {
                                    showingAcc = true
                                }, label: {
                                    Image(systemName: "person.crop.circle") // TODO: Profile pictures... eventually.
                                })
                                
                                Button(action: {
                                    showingPrefs = true
                                }, label: {
                                    Image(systemName: "gear")
                                })
                                
                                #if DEBUG
                                NavigationLink(destination: TestingView()) {
                                    Image(systemName: "laptopcomputer.and.iphone")
                                }
                                #endif
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingPrefs, onDismiss: { showingPrefs = false }) {
                SettingsView()
            }
            .sheet(isPresented: $showingAcc, onDismiss: { showingAcc = false }) {
                AccountPage()
            }
            .onAppear {
                updateCards()
            }
            .onChange(of: ExploitKit.shared.isTrollStore) {new in
                updateCards()
            }
            .onChange(of: backgroundApplyingEnabled) {new in
                updateCards()
            }
            .onChange(of: sourcedRepoFetcher.userToken) {new in
                updateCards()
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    func updateCards() {
        randomChance = Int.random(in: 0...1000)
        tweakManager.updateInstalledPackages()
        updateInProgress = true
        //let noTweaks = try? FileManager.default.contentsOfDirectory(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Tweaks").path).isEmpty
        cards = []
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            cards.append(.init(title: "Get Tweaks", description: "Explore tweaks in the Explore page!", symbol: "safari", buttonLabel: "Take me there", buttonSymbol: "arrow.right", buttonAction: {currentTab = .explore}))
            cards.append(.init(title: "Background refresh off", description: "Enable background refresh to ensure tweaks get applied consistently.", symbol: "exclamationmark.triangle.fill", buttonLabel: "Settings", buttonSymbol: "arrow.right", buttonAction: {showingPrefs = true}))
            cards.append(.init(title: "Log in", description: "Log in to your Sourced Repo account to get the most out of OpenPicasso.", symbol: "person.badge.key", buttonLabel: "Log in", buttonSymbol: "arrow.right", buttonAction: {showingAcc = true}))
        } else {
            if !ExploitKit.shared.isTrollStore {
                cards.append(.init(title: "No TrollStore detected", description: "Functionality will be limited. Install TrollStore using the tweak in Explore and reinstall OpenPicasso through there.", symbol: "exclamationmark.triangle.fill", buttonLabel: "Take me there", buttonSymbol: "arrow.right", buttonAction: {currentTab = .explore}, urgency: .high))
            }
            
            if !backgroundApplyingEnabled {
                cards.append(.init(title: "Background refresh off", description: "Enable background refresh to ensure tweaks get applied consistently.", symbol: "exclamationmark.triangle.fill", buttonLabel: "Settings", buttonSymbol: "arrow.right", buttonAction: {showingPrefs = true}))
            }
            
            if sourcedRepoFetcher.userToken == nil {
                cards.append(.init(title: "Log in", description: "Log in to your Sourced Repo account to get the most out of OpenPicasso.", symbol: "person.badge.key", buttonLabel: "Log in", buttonSymbol: "arrow.right", buttonAction: {showingAcc = true}))
            }
            
            if tweakManager.installedPackages.isEmpty {
                cards.append(.init(title: "Get Tweaks", description: "Explore tweaks in the Explore page!", symbol: "safari", buttonLabel: "Take me there", buttonSymbol: "arrow.right", buttonAction: {currentTab = .explore}))
            }
            
            cards.append(.init(title: "Join our Discord", description: "Discuss TrollStore 2, ask for help or just chat on our official server!", image: "discord", buttonLabel: "Join Discord", buttonSymbol: "arrow.right", buttonAction: { UIApplication.shared.open(.init(string: "https://discord.gg/hQeswU54pn")!)}))
            
            #if DEBUG
            cards.append(.init(title: "High Urgency", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris rutrum accumsan risus, at eleifend ex mollis sed.", symbol: "exclamationmark.triangle.fill", buttonLabel: "Lorem Ipsum", buttonSymbol: "arrow.right", buttonAction: {currentTab = .explore}, urgency: .high))
            cards.append(.init(title: "Medium Urgency", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris rutrum accumsan risus, at eleifend ex mollis sed.", symbol: "exclamationmark.triangle.fill", buttonLabel: "Lorem Ipsum", buttonSymbol: "arrow.right", buttonAction: {currentTab = .explore}, urgency: .medium))
            cards.append(.init(title: "Low Urgency", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris rutrum accumsan risus, at eleifend ex mollis sed.", symbol: "exclamationmark.triangle.fill", buttonLabel: "Lorem Ipsum", buttonSymbol: "arrow.right", buttonAction: {currentTab = .explore}, urgency: .low))
            cards.append(.init(title: "No Urgency", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris rutrum accumsan risus, at eleifend ex mollis sed.", symbol: "exclamationmark.triangle.fill", buttonLabel: "Lorem Ipsum", buttonSymbol: "arrow.right", buttonAction: {currentTab = .explore}, urgency: .none))
            #endif
        }
        updateInProgress = false
    }
}

enum TipUrgency {
    case none,low,medium,high
}

struct Card: Identifiable {
    var id = UUID()
    
    var title: String
    var description: String
    var symbol: String?
    var image: String?
    
    var buttonLabel: String
    var buttonSymbol: String
    var buttonAction: () -> Void
    
    var urgency: TipUrgency = .none
}

struct TipCard: View {
    var info: Card
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Group {
                    if let symbol = info.symbol {
                        Image(systemName: symbol)
                    } else if let image = info.image {
                        Image(image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                    }
                }
                .imageScale(.medium)
                .foregroundColor(
                    (info.urgency == .low) ? Color(UIColor.systemYellow) : (info.urgency == .medium) ? Color(UIColor.systemOrange) : ((info.urgency == .high) ? Color(UIColor.systemRed) : .accentColor)
                )
                Text(info.title)
                    .font(.headline)
                Spacer()
            }
            .padding(.top, 16)
            Text(info.description)
                .foregroundColor(.secondary)
                .lineLimit(2)
            Spacer()
            Button {
                info.buttonAction()
            } label: {
                Label(info.buttonLabel, systemImage: info.buttonSymbol)
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 16)
            .buttonStyle(.bordered)
            .tint(.accentColor)
        }
        .padding(.horizontal, 14)
        .frame(height: 180)
        .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerSize: CGSize(size: 16)))
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewPreviewWrapper()
    }
}


struct HomeViewPreviewWrapper : View {
    @State private var value: SelectableTab = .explore
    
    var body: some View {
        HomeView(currentTab: $value)
    }
}

struct TipCard_Previews: PreviewProvider {
    static var previews: some View {
        TipCard(info: .init(title: "No TrollStore detected", description: "Functionality will be limited. Install TrollStore using the tweak in Explore and reinstall OpenPicasso through there.", symbol: "exclamationmark.triangle.fill", buttonLabel: "Take me there", buttonSymbol: "arrow.right", buttonAction: {}, urgency: .high))
            .padding([.all],4)
    }
}
