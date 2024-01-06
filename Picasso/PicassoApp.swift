//
//  PicassoApp.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-04.
//

import SwiftUI
import TelemetryClient
import WelcomeSheet
import NavigationTransitions

var fullLog: [String.SubSequence] = []

var log: String = ""

class AirTrollerStatus: ObservableObject {
    static var shared = AirTrollerStatus()
    @Published var isRunning: Bool = false
}

#Preview {
    ZStack {
        Rectangle()
            .foregroundStyle(Gradient(colors: [.blue, .indigo, .purple]))
            .ignoresSafeArea(.all)
        AirTrollerIndicator()
    }
}

let appVersion: String = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))"
let funnyMessages: [String] = ["Bite me!", "Say hello to Cowabunga v10", "It's so sad Steve Jobs died of ligma", "🫁", "Nine parts Copilot", "Lucky for you, it's snack time", "Wait, it's all Mandela Pro?", "I want a frickin' ninja star!", "Still a better name than Halcyon", "Just pop it in your mouth"] // SKANKPHONE?!

#if DEBUG
let isDebug = true
#else
let isDebug = false
#endif

let unexpectedErrorString = "Something went very horribly wrong, in a very unexpected manner. Please contact the Picasso Team and provide steps on how to reproduce the error."

func remLog(_ objs: Any...) {
    for obj in objs {
        let args: [CVarArg] = [ "[OpenPicasso \(Date())] \(String(describing: obj))" ]
        withVaList(args) { RLogv("%@", $0) }
    }
}

struct AirTrollerIndicator: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: 12, height: 12)
                .foregroundColor(Color(UIColor.systemGreen))
            Text("An AirTroller session is in progress")
        }
        .padding()
        .background(Capsule().foregroundStyle(.regularMaterial))
    }
}

@main
struct PicassoApp: App {
    @StateObject var sourcedRepoFetcher = SourcedRepoFetcher.shared
    
    @AppStorage("puafMethod") private var puafMethod: Int = KFD.puaf_method
    @AppStorage("puafPagesIndex") private var puafPagesIndex: Int = KFD.puaf_pages_index
    @AppStorage("kreadMethod") private var kreadMethod: Int = KFD.kread_method
    @AppStorage("kwriteMethod") private var kwriteMethod: Int = KFD.kwrite_method
    @AppStorage("firstOpen") private var firstTime: Bool = true
    @AppStorage("currentExploit") private var currentExploit: String = ExploitKit.shared.selectedExploit.rawValue
    
    
    @AppStorage("needsCatalogFixup") private var needsCatalogFixup: Bool = false
    
    @State var welcomeSheetPresented = false
    @State var loggedIn = false
    @State var ready = false
    
    @State var showFixupView = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var observers = [NSObjectProtocol]()
    
    // analytics
    let analyticsEnabled = false
    
    init() {
        observers.append(
            NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
                ExploitKit.shared.CleanUp()
            }
        )
    }
    
    var body: some Scene {
        WindowGroup {
            if firstTime || sourcedRepoFetcher.showLogin {
                InitialOnboardingView()
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
            } else {
                ZStack(alignment: .top) {
                    RootView()
                    if AirTrollerStatus.shared.isRunning {
                        AirTrollerIndicator()
                    }
                        
                }
                    .navigationTransition(.slide.animation(.interpolatingSpring(stiffness: 0.8, damping: 0.5)))
                    .onReceive(NotificationCenter.default.publisher(for: LogStream.shared.reloadNotification)) { _ in
                        DispatchQueue.global(qos: .utility).async {
                            guard let AttributedText = LogStream.shared.outputString.copy() as? NSAttributedString else {
                                fullLog = ["Error Getting Log!"]
                                return
                            }
                            fullLog = AttributedText.string.split(separator: "\n")
                            // scroll.scrollTo(LogItems.count - 1)
                        }
                    }
                    .sheet(isPresented: $showFixupView) {
                        ThemeCatalogFixView()
                    }
//                    .sheet(isPresented: $sourcedRepoFetcher.showLogin, content: {
//                        LoginView(onLogin: exploitAndDRM)
//                    })
                
                    .welcomeSheet(isPresented: $welcomeSheetPresented, isSlideToDismissDisabled: true, preferredColorScheme: colorScheme, pages: [
                        WelcomeSheetPage(title: "Welcome to OpenPicasso!", rows: [
                            WelcomeSheetPageRow(imageSystemName: "wrench.and.screwdriver.fill", title: "Create", content: "Create your own tweaks in the Create tab."),
                            WelcomeSheetPageRow(imageSystemName: "safari", title: "Explore", content: "Explore tweaks made by us and the community."),
                            WelcomeSheetPageRow(imageSystemName: "paintbrush.fill", title: "Customize", content: "Customize your device to the maximum!"),
                        ], accentColor: .accentColor),
                    ])
                    .onAppear {
                        onOpen()
                    }
                    .transition(.opacity.animation(.linear(duration: 1.0)))
                    .onOpenURL { url in
                        onOpen()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            do {
                                try handleURL(url: url)
                            } catch {
                                UIApplication.shared.alert(body: error.localizedDescription)
                            }
                        }
                    }
                //                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { _ in
                //                    if loggedIn {
                //                        ExploitKit.shared.CleanUp()
                //                    }
                //                })
                //                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: { output in
                //                    if loggedIn {
                //                        ExploitKit.shared.CleanUp()
                //                    }
                //                })
                //                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { output in
                //                    if loggedIn {
                //                        UIApplication.shared.alert(title: "Exploiting...", body: "Praying to RNGesus"/*messages[(String(Int.random(in: 0...100000)).count - 1) / 2]*/, withButton: false)
                //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //                            ExploitKit.shared.Initialize()
                //                            UIApplication.shared.dismissAlert(animated: false)
                //                        }
                //                    }
                //                })
            }
        }
    }
    
    func handleURL(url: URL) throws {
        if url.absoluteString.starts(with: "picasso://") {
            do {
                try handleSpecialURL(url: url)
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        } else if url.pathExtension.lowercased() == "picasso" {
            do {
                try handleFile(url: url)
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
    }
    
    func handleSpecialURL(url: URL) throws {
        
    }
    
    func handleFile(url: URL) throws {
        
    }
    
    func onOpen() {
        KFD.puaf_method = puafMethod
        KFD.puaf_pages_index = puafPagesIndex
        KFD.kread_method = kreadMethod
        KFD.kwrite_method = kwriteMethod
        print("[Info] OpenPicasso version \(appVersion), Using \(KFD.puaf_pages_options[UserDefaults.standard.integer(forKey: "puafMethod")]) for PUAF")
        print("[Info] Running on \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
        print(funnyMessages.count)
        
        do {
#if targetEnvironment(simulator)
#else
            ExploitKit.shared.SelectExploit()
#endif
            
//            print("[Analytics] Initializing Analytics...")
//            let configuration = TelemetryManagerConfiguration(appID: telemetryDeckID)
//            
//            if telemetryDeckID == "" {
//                print("[Analytics] App built without valid Telemetry App ID!")
//            } else {
//                if analyticsEnabled { // also this lol
//                    // initialize analytics
//                    configuration.defaultUser = sourcedRepoFetcher.email ?? ""
//                    TelemetryManager.initialize(with: configuration)
//                    print("[Analytics] Sending app launch signal!")
//                    TelemetryManager.send("appLaunchedRegularly")
//                } else {
//                    print("[Analytics] Analytics disabled by user.")
//                    configuration.analyticsDisabled = true
//                    TelemetryManager.initialize(with: configuration)
//                }
//            }
            
            if sourcedRepoFetcher.userToken != nil {
                exploitAndDRM()
            }
        } catch {
#if targetEnvironment(simulator)
#else
            UIApplication.shared.alert(title: "Unsupported Device", body: error.localizedDescription, animated: true, withButton: false)
#endif
        }
    }
    
    func exploitAndDRM() {
        Task {
            UIApplication.shared.alert(title: "Logging in...", body: "This shouldn't take longer than 1 second.", withButton: false)
            do {
//                try await doDRMCheck(s: UserDefaults.standard.string(forKey: "userToken")!)
                loggedIn = true
            } catch {
                UIApplication.shared.change(title: "Error", body: "An error occured while validating your license. \(error.localizedDescription)\n\n (Logging out usually resolves unknown issues)", addCancelWithTitle: "Log Out", onCancel: {
//                    #if DEBUG
//                    UserDefaults.standard.set(nil, forKey: "customBackendURL")
//                    #else
                    sourcedRepoFetcher.logout()
//                    #endif
                })
                return
            }
            if TARGET_OS_SIMULATOR == 0 {
                //            let messages = ["This shouldn't take long", "Praying to RNGesus", "Ultra secret message"]
                if ExploitKit.shared.selectedExploit != .none {
                    UIApplication.shared.change(title: "Exploiting...", body: "Praying to RNGesus" /* messages[(String(Int.random(in: 0...100000)).count - 1) / 2] */ )
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    do {
                        try ExploitKit.shared.Initialize()
                    } catch {
                        UIApplication.shared.dismissAlert(animated: true)
                        UIApplication.shared.alert(body: "Exploit Error: \(error.localizedDescription). Some functionality may be limited.")
                    }
                    
                    // MARK: - Exploited
                    
                    UIApplication.shared.dismissAlert(animated: true)
                    if UserDefaults.standard.bool(forKey: "backgroundApplyingEnabled") {
                        if !UserDefaults.standard.bool(forKey: "wasBackgroundRefreshing") {
                            BackgroundFileUpdaterController.shared.restartTimer()
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if firstTime {
                                    welcomeSheetPresented = true
                                } else {
                                    welcomeSheetPresented = false
                                }
                                firstTime = false
                                checkForUpdates()
                            }
                            
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                UIApplication.shared.alert(title: "OpenPicasso crashed", body: "OpenPicasso has crashed during the last Background Refresh and has been disabled. Please remove any incompatible tweaks and re-enable Background Refresh in settings.")
                                UserDefaults.standard.set(false, forKey: "wasBackgroundRefreshing")
                                UserDefaults.standard.set(false, forKey: "backgroundApplyingEnabled")
                            }
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if needsCatalogFixup {
                            catalogFix()
                        }
                    }
                }
            } else {
                UIApplication.shared.dismissAlert(animated: true)
                // simulator, start background refresh right away
                if UserDefaults.standard.bool(forKey: "backgroundApplyingEnabled") {
                    BackgroundFileUpdaterController.shared.restartTimer()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    checkForUpdates()
                }
            }
        }
    }
    
    func checkForUpdates() {
        Task {
            guard let (version, build, changelog) = try? await sourcedRepoFetcher.getLatestVersion(shortName: "picasso") else { return }
            
            // verify both version and build number
            if version != Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String || build != Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                UIApplication.shared.confirmAlert(title: "Update Available", body: "An update is available for OpenPicasso. Please update to the latest version to get the best experience.\n\nChangelog:\n\(changelog)", confirmTitle: "Download Update", cancelTitle: "Remind me later", onOK: {
                    UIApplication.shared.open(URL(string: "https://repo.sourceloc.net/package/picasso")!)
                }, noCancel: false)
            }
        }
    }
    
    func catalogFix() {
        showFixupView = true
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.75) {
//            do {
//                try CatalogThemeManager.shared.uncorruptCatalogs()
//                UserDefaults.standard.set(false, forKey: "needsCatalogFixup")
//                UIApplication.shared.dismissAlert(animated: false)
//            } catch {
//                UIApplication.shared.change(body: "\(error.localizedDescription)")
//            }
//        }
    }
}
