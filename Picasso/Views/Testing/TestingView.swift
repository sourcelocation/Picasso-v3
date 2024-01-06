//
//  TestingView.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-19.
//

import NavigationBackport
import URLBackport
import SwiftUI

/// TestingView: DevTest? Staging? Guess we'll never know...
struct TestingView: View {
    @State private var message: String? = nil
    //    @State private var currentMessage: String = ""
    @State private var testStringVar: String = ""
    
    @State private var showLogin: Bool = false
    
    @State private var showPurchase: Bool = false
    
    @State private var showWeb: Bool = false
    @State private var showWeb2: Bool = false
    
    @AppStorage("customBackendURL") private var custombackend: String = ""
    @AppStorage("installationserverurl") private var installationserverurl: String = ""
    @AppStorage("DisableStupidQuotes") private var DisableStupidQuotes: Bool = false
    
    @AppStorage("currentExploit") private var currentExploit: String = ExploitKit.shared.selectedExploit.rawValue
    
    @AppStorage("unifiedTweaks") private var unifiedTweaks: Bool = false
    
    init() {
        /// https://gist.github.com/vinhnx/5b78bc13bfbc5d1070a5
        UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)
        //UIToolbar.appearance().setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        UIToolbar.appearance().isTranslucent = true
        
        if DisableStupidQuotes {
            nilMessage()
        }
    }
    
    private func nilMessage() { message = nil }
    
    var body: some View {
        //Navigator {
            VStack(alignment: .center) {
                List {
                    Section(header: Label("Developer Settings", systemImage: "laptopcomputer.and.iphone"), footer: Label("choose your favourite three letter exploit.\nfor bomberfish: exploitkit says \"\(ExploitKit.shared.selectedExploit.rawValue)\"", systemImage: "info.circle")) {
                        //Toggle("exploitKitEnabled", isOn: $exploitKitEnabled)
                        TextField("Custom Sourced Backend URL", text: $custombackend)
                        TextField("Installation Server URL", text: $installationserverurl)
                        Link(destination: URLtoTS(.init(string: installationserverurl))) {
                            Text("Install OpenPicasso update from server")
                        }
                        
                        Picker("Force Override currentExploit", selection: $currentExploit, content: {
                            Text("KFD").tag(ExploitType.kfd.rawValue)
                            Text("MDC").tag(ExploitType.mdc.rawValue)
                            Text("None").tag(ExploitType.none.rawValue)
                        })
                        .onChange(of: currentExploit) { selected in
                            print("[DEBUG!!!] \(selected) picked")
                            KFD.kclose()
                            exitApp()
                        }
                        
                        Toggle("Enable Unified Tweaks Menu", isOn: $unifiedTweaks)
                    }
                    
                    Section("In case you were using MDC") {
                        Button("kopen", action: {
                            KFD.kopen()
                            Haptic.shared.notify(.success)
                        })
                        Button("kclose", action: {
                            KFD.kclose()
                            Haptic.shared.notify(.success)
                        })
                    }
                    
                    Section("exploit stuff") {
                        NavigationLink("APPLICATIONMANAGER DEMO", destination: AppCommanderKFDPortRealWorkingNoVirus())
                        NavigationLink("SkunkFileManager", destination: SkunkFileManager(at: .init(fileURLWithPath: "/")))
                        NavigationLink("AUTOREDIRECT DEMO", destination: AutoRedirectDemoView(at: .init(fileURLWithPath: "/var")))
                        Button("test sb escape thingie", action: {
                            let varPath = strdup(("/private/var" as NSString).utf8String)
                            let vnode: UInt64 = getVnodeAtPathByChdir(varPath)
                            let mountPath: URL = .init(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/mounted")
                            let status: UInt64 = createFolderAndRedirect(vnode, mountPath.path)
                            UIApplication.shared.alert(title: "Success?", body: "createFolderAndRedirect returns \(status), prob mounted at \(mountPath) kekw")
                        })
                        
                        NavigationLink("go to mount path", destination: SimpleFMView(at: .init(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/mounted")))
                        NavigationLink("test simplefmview", destination: SimpleFMView(at: .init(fileURLWithPath: NSHomeDirectory())))
                    }
                    
                    Section("super secret upcoming features") {
                        NavigationLink("TrollStore Testing", destination: TSTestingView())
                        NavigationLink("Twerk Injection", destination: TweakInjectView())
                        Button("purchase modal") {
                            showPurchase = true
                        }
//                        .sheet(isPresented: $showPurchase) {
//                            ThemePurchaseView(, themes: <#[SourcedRepoFetcher.RepoTheme]#>)
//                        }
                    }
                    
                    Section("test functionality") {
                        NavigationLink("favlist", destination: FavListView())
                        Button("show login") {
                            showLogin = true
                        }
                        NavigationLink("open webview") {
                            FancyWebView(url: .init(string: "https://google.com")!)
                        }
                        Button("open webview (sheet)") {
                            showWeb = true
                        }
                        NavigationLink("open webview (issheet true)") {
                            FancyWebView(url: .init(string: "https://google.com")!, isSheet: true)
                        }
                        Button("open webview (sheet, issheet false)") {
                            showWeb2 = true
                        }
                        Button("remove image cache") {
                            let url: URL = .backport.documentsDirectory.appendingPathComponent(Bundle.main.bundleIdentifier ?? "net.sourceloc.Picasso.Dev", isDirectory: true)
                            do {
                                try FileManager.default.removeItem(at: url)
                                Haptic.shared.notify(.success)
                            } catch {
                                Haptic.shared.notify(.error)
                                UIApplication.shared.alert(body: error.localizedDescription)
                            }
                        }
                    }
                    
                    Section("do a miniscule amount of tomfoolery") {
                        Button("crash app by breakpoint", role: .destructive, action: {
                            fatalError("trolley")
                        })
                        Button("other way to crash app", role: .destructive, action: {
                            let trollArray: [Int] = []
                            let _: String = trollArray[69420] as! String // this has gotta crash for sure
                        })
                        Button("exit(-1)", role: .destructive) {
                            exit(-1)
                        }
                        Button("crash but cooler", role: .destructive) {
                            crashProgram()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Text("\("[\(message ?? "")]") [v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")]")
                                .font(.system(.callout, design: .rounded))
                                .padding(.bottom, 4)
                    }
                }
                
                .sheet(isPresented: $showLogin, content: {
                    LoginView(onLogin: {print("logged in")})
                })
                
                .sheet(isPresented: $showWeb) {
                    FancyWebView(url: .init(string: "https://google.com")!, isSheet: true)
                }
                
                .sheet(isPresented: $showWeb2) {
                    FancyWebView(url: .init(string: "https://google.com")!, isSheet: false)
                }
                
                .onAppear {
                    message = funnyMessages.randomElement()
                }
            }
            .navigationTitle("DevTest")
            .navigationBarTitleDisplayMode(.large)
        //}
//        .onAppear {
//            currentMessage = messages.randomElement()!
//        }
    }
}

/// why did i make this :nfr:
struct SimpleFMView: View {
    private let fm: FileManager = .default
    public var at: URL
    var body: some View {
        List {
            ForEach(getContentsAtURLFunctionThatDoesntThrow(at), id: \.self) {file in
                if file.hasDirectoryPath || (try? file.resourceValues(forKeys: [.isSymbolicLinkKey]))?.isSymbolicLink ?? false {
                    NavigationLink(destination: SimpleFMView(at: file), label: {
                        Label(file.lastPathComponent, systemImage: "folder")
                    })
                } else {
                    Label(file.lastPathComponent, systemImage: "doc")
                }
            }
        }
        .navigationTitle(at.lastPathComponent)
        .modifier(AutoPad())
    }
    
    func getContentsAtURLFunctionThatDoesntThrow(_ url: URL) -> [URL] {
        do {
            return try fm.contentsOfDirectory(at: at, includingPropertiesForKeys: nil)
        } catch {
            return []
        }
    }
}

struct AutoRedirectDemoView: View {
    private let fm: FileManager = .default
    public var at: URL
    
    @State private var currentURL: URL = .Backport.documentsDirectory
    @State private var contents: [URL] = []
    
    var body: some View {
        List {
            ForEach(contents, id: \.self) {file in
                if file.hasDirectoryPath {
                    NavigationLink(destination: AutoRedirectDemoView(at: file), label: {
                        Label(file.lastPathComponent, systemImage: "folder")
                    })
                } else {
                    Label(file.lastPathComponent, systemImage: "doc")
                }
            }
        }
        .refreshable {
            do {
                currentURL = try KFD.mountFolderAtURL(at).mountURL
                contents = try fm.contentsOfDirectory(at: currentURL, includingPropertiesForKeys: nil)
            } catch {
                print(error)
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
        .onAppear {
            do {
                currentURL = try KFD.mountFolderAtURL(at).mountURL
                contents = try fm.contentsOfDirectory(at: currentURL, includingPropertiesForKeys: nil)
            } catch {
                print(error)
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
        
        .navigationTitle(at.lastPathComponent)
    }
}

struct SkunkFileManager: View {
    private let fm: FileManager = .default
    public var at: URL
    
    @State private var currentURL: URL = .Backport.documentsDirectory
    @State private var contents: [URL] = []
    @State var currentMountPoint: URL = .Backport.documentsDirectory
    
    @State var currentOrigToVData: UInt64 = 0
    
    var body: some View {
        List {
            ForEach(contents, id: \.self) {file in
                if file.hasDirectoryPath || (try? file.resourceValues(forKeys: [.isSymbolicLinkKey]))?.isSymbolicLink ?? false {
                    NavigationLink(destination: SkunkFileManager(at: file), label: {
                        Label(file.lastPathComponent, systemImage: "folder")
                    })
                    .contextMenu {
                        Button("Delete") {
                            do {
                                try fm.removeItem(at: file)
                                Haptic.shared.notify(.success)
                            } catch {
                                UIApplication.shared.alert(body: error.localizedDescription)
                                Haptic.shared.notify(.error)
                            }
                        }
                    }
                } else {
                    Label(file.lastPathComponent, systemImage: "doc")
                        .contextMenu {
                            Button("Delete") {
                                do {
                                    try fm.removeItem(at: file)
                                    Haptic.shared.notify(.success)
                                } catch {
                                    UIApplication.shared.alert(body: error.localizedDescription)
                                    Haptic.shared.notify(.error)
                                }
                            }
                        }
                }
            }
        }
        .modifier(AutoPad())
        .refreshable {
            do {
                currentURL = at
                let contentsGet = try getContents(currentURL)
                contents = contentsGet.contents
                currentMountPoint = contentsGet.mountPoint
                currentOrigToVData = contentsGet.orig_to_v_data
            } catch {
                print(error)
                UIApplication.shared.alert(body: error.localizedDescription)
                Haptic.shared.notify(.error)
            }
        }
        .onAppear {
            do {
                currentURL = at
                let contentsGet = try getContents(currentURL)
                contents = contentsGet.contents
                currentMountPoint = contentsGet.mountPoint
                currentOrigToVData = contentsGet.orig_to_v_data
            } catch {
                print(error)
                UIApplication.shared.alert(body: error.localizedDescription)
                Haptic.shared.notify(.error)
            }
        }
        
        .onDisappear {
            if currentOrigToVData != 0 {
                try? KFD.unmountFileAtURL(mountURL: currentURL, orig_to_v_data: currentOrigToVData)
            }
        }
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(content: {
                    Button("Touch test.txt") {
                        do {
                            let data: Data = .init(count: 0)
                            try data.write(to: currentMountPoint.appendingPathComponent("test.txt"))
                            let contentsGet = try getContents(currentURL)
                            contents = contentsGet.contents
                            currentMountPoint = contentsGet.mountPoint
                            currentOrigToVData = contentsGet.orig_to_v_data
                        } catch {
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    }
                }, label: {Label("", systemImage: "ellipsis.circle")})
            }
        }
        .navigationTitle(at.lastPathComponent)
    }
    
    func getContents(_ at: URL) throws -> (mountPoint: URL, contents: [URL], orig_to_v_data: UInt64) {
        print("[SkunkFM] using filemanager")
        guard let contents = try? fm.contentsOfDirectory(at: at, includingPropertiesForKeys: nil) else {
            do {
                print("[SkunkFM] using kfd")
                let mount = try KFD.mountFolderAtURL(at)
                return try (mount.mountURL, fm.contentsOfDirectory(at: mount.mountURL, includingPropertiesForKeys: nil), mount.orig_to_v_data)
            } catch {
                print(error)
                throw error
            }
        }
        print("[SkunkFM] fm was successful")
        return (at, contents, 0)
    }
}

struct FavListView: View {
    @AppStorage("favouriteList") var favouriteList: [String] = []
    var body: some View {
        VStack {
            if favouriteList.isEmpty {
                Text("no favourites saved :(")
            }
            ForEach(favouriteList, id: \.self) {item in
                Text(item)
            }
        }
    }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView()
    }
}

struct AppCommanderKFDPortRealWorkingNoVirus: View {
    @State var apps: [SBApp] = []
    @State var tile: Bool = false
    var body: some View {
        List {
            ForEach(apps, id: \.bundleIdentifier) { app in
                AppCell(large: true, link: false, sbapp: app, tile: $tile)
            }
        }
        .onAppear {
            do {
                apps = try ApplicationManager.getApps()
            } catch {
                print(error)
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
        .navigationTitle("Applications")
    }
}

struct TSTestingView: View {
    var UDID2: String {
        let aaDeviceInfo: AnyClass? = NSClassFromString("A" + "A" + "D" + "e" + "v" + "i" + "c" + "e" + "I" + "n" + "f" + "o")
        return aaDeviceInfo?.value(forKey: "u"+"d"+"i"+"d") as? String ?? "Unknown"
    }
    var body: some View {
        List {
            Section("general info") {
                InfoCell(title: "Version", value: UIDevice.current.systemVersion)
                InfoCell(title: "App Installed with TrollStore", value: ExploitKit.shared.isTrollStore ? "Yes" : "No")
            }
            Section("identifying info") {
                InfoCell(title: "Model Number", value: MGGetStringAnswer(kMGModelNumber) as? String ?? "Unknown")
                InfoCell(title: "Serial Number", value: MGGetStringAnswer(kMGSerialNumber) as? String ?? "Unknown")
                InfoCell(title: "MLB Serial Number (???)", value: MGGetStringAnswer(kMGMLBSerialNumber) as? String ?? "Unknown")
                InfoCell(title: "UDID", value: MGGetStringAnswer(kMGUniqueDeviceID) as? String ?? "Unknown")
                InfoCell(title: "UDID (Method 2)", value: UDID2)
                
                InfoCell(title: "UDID Data (???)", value: MGGetStringAnswer(kMGUniqueDeviceIDData) as? String ?? "Unknown")
                InfoCell(title: "Uq. ChipID", value: MGGetStringAnswer(kMGUniqueChipID) as? String ?? "Unknown")
                InfoCell(title: "Die ID", value: MGGetStringAnswer(kMGDieID) as? String ?? "Unknown")
                InfoCell(title: "Arch", value: MGGetStringAnswer(kMGCPUArchitecture) as? String ?? "Unknown")
                InfoCell(title: "BB Serial", value: MGGetStringAnswer(kMGBasebandSerialNumber) as? String ?? "Unknown")
            }
            
//            Section("from udidinator") {
//                InfoCell(title: "UDID", value: UDIDInator.UDID)
//                InfoCell(title: "SN", value: UDIDInator.serialNumber)
//                InfoCell(title: "MLBSN", value: UDIDInator.logicBoardSN)
//                InfoCell(title: "IMEI", value: UDIDInator.IMEI)
//                InfoCell(title: "DeviceID", value: UDIDInator.generateDeviceID())
//                InfoCell(title: "DeviceID Decoded", value: .init(data: .init(base64Encoded: UDIDInator.generateDeviceID())!, encoding: .utf8)!)
//            }
        }
        .modifier(AutoPad())
        .navigationTitle("TS Testing")
    }
}

struct InfoCell: View {
    public var title: String
    public var value: String
    var body: some View {
        HStack {
            Text(title)
                .multilineTextAlignment(.leading)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
                .foregroundColor(.secondary)
        }
    }
}

//
//  AppCell.swift
//  Caché
//
//  Created by Hariz Shirazi on 2023-03-03.
//

// this is actually a HEAVILY modified LinkCell from cowabunga lol

struct AppCell: View {
//    var bundleid: String
//    var name: String
    var large: Bool
    var link: Bool
//    var bundleURL: URL
    var sbapp: SBApp
    @Binding var tile: Bool

    var body: some View {
        if link {
            //NavigationLink(destination: AppView(bundleId: bundleid, name: name, bundleurl: bundleURL, sbapp: sbapp)) {
                if tile {
                    VStack(alignment: .center) {
                        Group {
                            if let image = UIImage(contentsOfFile: try! KFD.mountFileAtURL(sbapp.bundleURL.appendingPathComponent(sbapp.pngIconPaths.first ?? "")).mountURL.path) {
                                Image(uiImage: image)
                                    .resizable()
                                    .background(Color.black)
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image("Placeholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        .cornerRadius(large ? 14 : 12)
                        .frame(width: large ? 68 : 58, height: large ? 68 : 58)
                        
                        VStack {
                            HStack {
//                                MarqueeText(text: name, font: UIFont.preferredFont(forTextStyle: large ? .title2 : .headline), leftFade: 16, rightFade: 16, startDelay: 1.25)
                                Text(sbapp.name)
                                    .font(large ? .title2 : .headline)
                                    .padding(.horizontal, 6)
                                Spacer()
                            }
                            HStack {
//                                MarqueeText(text: bundleid, font: UIFont.preferredFont(forTextStyle: large ? .headline : .footnote), leftFade: 16, rightFade: 16, startDelay: 1.25)
                                Text(sbapp.bundleIdentifier)
                                    .font(large ? .headline : .footnote)
                                    .padding(.horizontal, 6)
                                Spacer()
                            }
                        }
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .font(.system(.headline))
//                            .multilineTextAlignment(.center )
//                            .foregroundColor(Color(UIColor.secondaryLabel))
//                            .padding([.trailing], 10)
                    }
                    .foregroundColor(Color(UIColor.label))
                    .padding(10)
                    .padding([.vertical], 8)
                } else {
                    HStack(alignment: .center) {
                        Group {
                            if let image = UIImage(contentsOfFile: try! KFD.mountFileAtURL(sbapp.bundleURL.appendingPathComponent(sbapp.pngIconPaths.first ?? "")).mountURL.path) {
                                Image(uiImage: image)
                                    .resizable()
                                    .background(Color.black)
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image("Placeholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        .cornerRadius(large ? 14 : 12)
                        .frame(width: large ? 58 : 48, height: large ? 58 : 48)
                        
                        VStack {
                            HStack {
//                                MarqueeText(text: name, font: UIFont.preferredFont(forTextStyle: large ? .title2 : .headline), leftFade: 16, rightFade: 16, startDelay: 1.25)
                                Text(sbapp.name)
                                    .font(large ? .title2 : .headline)
                                    .padding(.horizontal, 6)
                                Spacer()
                            }
                            HStack {
//                                MarqueeText(text: bundleid, font: UIFont.preferredFont(forTextStyle: large ? .headline : .footnote), leftFade: 16, rightFade: 16, startDelay: 1.25)
                                Text(sbapp.bundleIdentifier)
                                    .font(large ? .headline : .footnote)
                                    .padding(.horizontal, 6)
                                Spacer()
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(.headline))
                            .multilineTextAlignment(.center )
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .padding([.trailing], 10)
                    }
                    .foregroundColor(Color(UIColor.label))
                    
                        .padding(10)
                        .padding([.vertical], 8)
                }
            //}
        } else {
            VStack {
                HStack(alignment: .center) {
                    Group {
                        if let image = UIImage(contentsOfFile: sbapp.bundleURL.appendingPathComponent(sbapp.pngIconPaths.first ?? "").path) {
                            Image(uiImage: image)
                                .resizable()
                                .background(Color.black)
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image("Placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .cornerRadius(large ? 14 : 12)
                    .frame(width: large ? 58 : 48, height: large ? 58 : 48)

                    VStack {
                        HStack {
//                                MarqueeText(text: name, font: UIFont.preferredFont(forTextStyle: large ? .title2 : .headline), leftFade: 16, rightFade: 16, startDelay: 1.25)
                            Text(sbapp.name)
                                .font(large ? .title2 : .headline)
                                .padding(.horizontal, 6)
                            Spacer()
                        }
                        HStack {
//                                MarqueeText(text: bundleid, font: UIFont.preferredFont(forTextStyle: large ? .headline : .footnote), leftFade: 16, rightFade: 16, startDelay: 1.25)
                            Text(sbapp.bundleIdentifier)
                                .font(large ? .headline : .footnote)
                                .padding(.horizontal, 6)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}
