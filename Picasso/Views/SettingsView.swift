//
//  SettingsView.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-04.
//

import NavigationBackport
import SwiftUI
import WelcomeSheet

struct SettingsView: View {
    // General
    @AppStorage("backgroundApplyingEnabled") var backgroundApplyingEnabled: Bool = false
    
    // Exploit
    @AppStorage("currentExploit") private var currentExploit: String = ExploitKit.shared.selectedExploit.rawValue
    @AppStorage("puafMethod") private var puafMethod: Int = KFD.puaf_method
    @AppStorage("puafPagesIndex") private var puafPagesIndex: Int = KFD.puaf_pages_index
    @AppStorage("kreadMethod") private var kreadMethod: Int = KFD.kread_method
    @AppStorage("kwriteMethod") private var kwriteMethod: Int = KFD.kwrite_method
    @AppStorage("firstOpen") private var firstTime: Bool = true
    
    // Creator
    @AppStorage("creatorMode") private var creatorMode: Bool = false
    @AppStorage("bundleID") private var bundlePrefix: String = "com.\(UserDefaults.standard.string(forKey: "username")?.lowercased() ?? "example")"
    @AppStorage("authorName") private var authorName: String = UserDefaults.standard.string(forKey: "username") ?? "You!"
    
    // Experimental
    @AppStorage("varAccess") var varAccess: Bool = false
    @AppStorage("aggressiveApplying") var aggressiveApplying: Bool = false
    
    @AppStorage("unifiedTweaks") private var unifiedTweaks: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    @StateObject var sourcedRepoFetcher = SourcedRepoFetcher.shared
    
    @State var showingChangePasswordAlert = false
    @State var newPasswordInput = ""
    @State var repeatPasswordInput = ""
    
    // Exploit Information Sheet
    @State var presentExploitInfo = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Navigator {
            List {
                NavigationLink(destination: AboutView(), label: {
                    Label("About OpenPicasso", systemImage: "info.circle")
                })
                Section(header: Label("General", systemImage: "gearshape")) {
                    Toggle(isOn: $backgroundApplyingEnabled) { Text("Background Applying") }
                        .tint(.accentColor)
                        .onChange(of: backgroundApplyingEnabled) { _ in
                            if backgroundApplyingEnabled {
                                UIApplication.shared.confirmAlert(title: "Actions required",
                                                                  body: "For Background Applying to work, the app needs the following permissions:\n\n- Location\n- Notifications\n\nLocation is never sent  anywhere, and is only used to keep the app running forever.", confirmTitle: "Continue", onOK: {
                                                                      BackgroundFileUpdaterController.shared.restartTimer()
                                                                  }, noCancel: true)
                            }
                        }
                    NavigationLink(destination: LogView(), label: {
                        Label("Debug Logs", systemImage: "terminal")
                    })
                }
                
                if creatorMode {
                    Section(header: Label("Creator Options", systemImage: "shippingbox")) {
                        HStack {
                            Text("Package Author Name")
                            // .font(.caption)
                            Spacer()
                            TextField(UserDefaults.standard.string(forKey: "username") ?? "You!", text: $authorName)
                                // .font(.system(.body, design: .monospaced))
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Bundle ID Prefix")
                            // .font(.caption)
                            Spacer()
                            TextField("com.\(UserDefaults.standard.string(forKey: "username")?.lowercased() ?? "example")", text: $bundlePrefix)
                                // .font(.system(.body, design: .monospaced))
                                .autocapitalization(.none)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                Section(header: Label("Exploit", systemImage: "screwdriver"), footer: Label("Only change these settings if OpenPicasso doesn't work on your device.", systemImage: "info.circle")) {
                    HStack {
                        Picker("Exploit", selection: $currentExploit, content: {
                            ForEach(ExploitKit.shared.GetCompatibleExploits(), id: \.self) { exploit in
                                Text(ExploitKit.shared.ExploitTypeToName(exploit))
                                    .tag(exploit.rawValue)
                            }
                        })
                        .onChange(of: currentExploit) { selected in
                            // print("[DEBUG!!!] \(selected) picked")
                            if selected == ExploitType.mdc.rawValue || selected == ExploitType.none.rawValue {
                                KFD.kclose()
                            }
                            exitApp()
                        }
                        
                        Button {
                            presentExploitInfo.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .welcomeSheet(isPresented: $presentExploitInfo, isSlideToDismissDisabled: true, preferredColorScheme: colorScheme, pages: [
                            WelcomeSheetPage(title: "Exploit Information", rows: [
                                WelcomeSheetPageRow(imageNamed: "cow", title: "MDC (MacDirtyCow)", content: "MacDirtyCow is the most stable exploit and works on almost every device. It abuses a bug in XNU's virtual memory system to permanently modify any file in /var and temporarily change files in /System. This exploit supports iOS 15 versions up to 15.7.1 and iOS 16 versions up to 16.1.2."),
                                WelcomeSheetPageRow(imageSystemName: "doc", title: "KFD (Kernel File Descriptor)", content: "KFD is similar to MDC but a lot less stable. It requires individual kernel offsets for every device and doesn't have a 100% exploit success rate. It's a bit more powerful than MDC but not by a lot. This exploit supports some versions of iOS 15 and any version of iOS 16."),
                                WelcomeSheetPageRow(imageNamed: "trollsimple", title: "None (TrollStore-only)", content: "This option doesn't utilize any exploit. Instead, it uses private entitlements obtained through TrollStore to bypass the iOS sandbox. Because this option doesn't utilize any exploit, it's impossible to overwrite files in /System, which means some tweaks such as Dock or Hide Home Bar won't work with this option."),
                            ], accentColor: .accentColor),
                        ])
                        .buttonStyle(.bordered)
                    }
                    
                    if currentExploit == ExploitType.kfd.rawValue {
                        Group {
                            Picker("PUAF Method", selection: $puafMethod) {
                                let compat = KFD.getCompatiblePUAFMethods()
                                Group {
                                    if compat.contains("smith") {
                                        Text("Smith").tag(1).font(.system(.body, design: .monospaced))
                                    }
                                    if compat.contains("physpuppet") {
                                        Text("PhysPuppet").tag(0).font(.system(.body, design: .monospaced))
                                    }
                                    if compat.contains("landa") {
                                        Text("Landa (Experimental)").tag(2).font(.system(.body, design: .monospaced))
                                    }
                                }
                                .font(.system(.body, design: .monospaced))
                            }
                            .onChange(of: puafMethod) { method in
                                print(method)
                                print(KFD.puaf_method_options[method])
                                if method == 2 {
                                    UIApplication.shared.confirmAlertDestructive(title: "⚠️ Warning ⚠️", body: "Landa support is still under development and there is a 99% chance it won't work on your device. Do you still wish to use it?", onOK: {
                                        puafMethod = 2
                                        UIApplication.shared.dismissAlert(animated: true)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            UIApplication.shared.alert(title: "Important", body: "You have enabled Landa. Please reopen OpenPicasso to use it. If at any time you want to switch back to a stable PUAF method, please reinstall OpenPicasso.")
                                        }
                                    }, onCancel: {puafMethod = 1} , destructActionText: "Yes, do as I say!")
                                }
                            }
                            
                            Picker("Pages", selection: $puafPagesIndex) {
                                Group {
                                    Text("16").tag(0).font(.system(.body, design: .monospaced))
                                    Text("32").tag(1).font(.system(.body, design: .monospaced))
                                    Text("64").tag(2).font(.system(.body, design: .monospaced))
                                    Text("128").tag(3).font(.system(.body, design: .monospaced))
                                    Text("256").tag(4).font(.system(.body, design: .monospaced))
                                    Text("512").tag(5).font(.system(.body, design: .monospaced))
                                    Text("1024").tag(6).font(.system(.body, design: .monospaced))
                                    Text("2048").tag(7).font(.system(.body, design: .monospaced))
                                    Text("65536").tag(8).font(.system(.body, design: .monospaced))
                                }
                                .font(.system(.body, design: .monospaced))
                            }
                            //                    .onChange(of: puafPagesIndex) {method in
                            //                        print(method)
                            //                        print(KFD.puaf_pages_options[method])
                            //                    }
                            
                            Picker("kread Method", selection: $kreadMethod) {
                                Group {
                                    Text("sem_open").tag(1).font(.system(.body, design: .monospaced))
                                    Text("kqueue_workloop_ctl").tag(0).font(.system(.body, design: .monospaced))
                                }
                                .font(.system(.body, design: .monospaced))
                            }
                            //                        .onChange(of: kreadMethod) {method in
                            //                            print(method)
                            //                            print(KFD.kread_method_options[method])
                            //                        }
                            
                            Picker("kwrite Method", selection: $kwriteMethod) {
                                Group {
                                    Text("sem_open").tag(1).font(.system(.body, design: .monospaced))
                                    Text("dup").tag(0).font(.system(.body, design: .monospaced))
                                }
                                .font(.system(.body, design: .monospaced))
                            }
                        }
                        .disabled(currentExploit != ExploitType.kfd.rawValue)
                    }
//                    .onChange(of: kwriteMethod) {method in
//                        print(method)
//                        print(KFD.kwrite_method_options[method])
//                    }
                    Button(action: {
                        currentExploit = ExploitKit.shared.GetRecommendedExploit().rawValue
                        
                        puafMethod = 1
                        puafPagesIndex = 7
                        kreadMethod = 1
                        kwriteMethod = 1
                    }, label: { Label("Reset to recommended defaults", systemImage: "arrow.counterclockwise") })
                        .contextMenu(menuItems: {
                            Button(role: .destructive, action: {
                                UserDefaults.standard.register(defaults: [:])
                                exitApp()
                            }, label: {
                                Label("Reset OpenPicasso", systemImage: "trash")
                                    .foregroundColor(Color(UIColor.systemRed))
                            })
                        })
                }
                
                Section(header: Label("Advanced", systemImage: "gearshape.2"), footer: Label("Creator Mode allows you to create your own tweaks.", systemImage: "info.circle")) {
                    Toggle(isOn: $creatorMode, label: {
                        HStack {
                            Text("Creator Mode")
//                            Button(action: {
//                                Haptic.shared.notify(.warning)
//                                UIApplication.shared.alert(title: "Creator Mode", body: "Creator Mode allows you to create your own tweaks!")
//                            }, label: {
//                                Label("", systemImage: "questionmark.circle")
//                            })
                        }
                    })
                    .tint(.accentColor)
                }
                
                Section(header: Label("Experimental", systemImage: "testtube.2")) {
                    Toggle(isOn: $aggressiveApplying) { Text("Aggressive applying") }
                        .tint(.accentColor)
                    Toggle("Enable Redesigned Tweaks Page", isOn: $unifiedTweaks)
                        .tint(.accentColor)
//                    if currentExploit != ExploitType.mdc.rawValue {
//                        Toggle(isOn: $varAccess) { Text("Allow tweaks to modify /var") }
//                            .tint(.accentColor)
//                    }
                }
                
//                Section(header: Label("Account", systemImage: "person")) {
//                    HStack {
//                        Text("Username")
//                        Spacer()
//                        Text("@\(sourcedRepoFetcher.username ?? "")")
//                            .foregroundColor(.secondary)
//                    }
//                    HStack {
//                        Text("Email")
//                        Spacer()
//                        Text("\(sourcedRepoFetcher.email ?? "")")
//                            .foregroundColor(.secondary)
//                    }
//                }
//                Section {
//                    Button {
//                        openURL(.init(string: "https://repo.sourceloc.net/account/general")!)
//                    } label: {
//                        Label("Change password", systemImage: "person.badge.key")
//                            .buttonStyle(.bordered)
//
//                    }
//                    Button {
//                        sourcedRepoFetcher.logout()
//                        dismiss()
//                    } label: {
//                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
//                            .buttonStyle(.bordered)
//                            .foregroundColor(.red)
//
//                    }
//                }
                Section {
                    // ShareLink(item: log, label: {Label("Share Debug Logs", systemImage: "square.and.arrow.up")})
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                if bundlePrefix == "" {
                    bundlePrefix = "com.\(UserDefaults.standard.string(forKey: "username")?.lowercased() ?? "example")"
                }
                if authorName == "" {
                    authorName = UserDefaults.standard.string(forKey: "username") ?? "You!"
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        CloseButton()
                    })
                })
            }
            .animation(.easeInOut(duration: 0.35), value: creatorMode)
            .animation(.easeInOut(duration: 0.35), value: currentExploit)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BruhView()
            .sheet(isPresented: .constant(true)) {
                SettingsView()
            }
    }
}
