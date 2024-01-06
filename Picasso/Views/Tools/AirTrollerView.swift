// bomberfish
// AirTrollerView.swift – Picasso
// created on 2023-12-11

import SwiftUI
import Photos

// technically gpl'ed but who the fuck cares :troll:
struct AirTrollerView: View {
    // For opening donation page
        @Environment(\.openURL) var openURL
        
        // Which people are selected
        @State var selectedPeople: [TDKSFNode: Bool] = [:]
        
        // Troll Controller, manages airdrop stuff
        @StateObject var trollController = TrollController.shared
        @State var rechargeDuration: Double = 0.5
        @State var showingImagePicker: Bool = false
        
        @State var totalAirDrops: Int = 0
        
        /// Custom selected image
        @State var imageURL: URL?
        
        private var gridItemLayout = [GridItem(.adaptive(minimum: 75, maximum: 100))]
        
        var body: some View {
            GeometryReader { geo in
                let hasHomeIndicator = geo.safeAreaInsets.bottom - 88 > 20
                Group {
                    if trollController.people.count == 0 { // No users in radius
                        VStack {
                            ProgressView()
                            Text("Searching for devices...")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    } else {
                        VStack {
                            ScrollView {
                                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                                    ForEach(trollController.people.sorted(by: { a, b in a.displayName ?? "" < b.displayName ?? "" }), id: \.node) { p in
                                        PersonView(person: p, selected: $selectedPeople[p.node])
                                            .environmentObject(trollController)
                                    }
                                }
                            }
                            .padding()
                            VStack {
                                if trollController.isRunning { Text("Sent AirDrops: \(totalAirDrops)") }
                                HStack { // delay control between airdrops
                                    Image(systemName: "timer")
                                    Slider(value: $rechargeDuration, in: 0.0...4.0)
                                    Text(String(format: "%.1fs", rechargeDuration))
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                                Button(action: {
                                    Haptic.shared.play(.soft) // mmm
                                    if imageURL == nil {
                                        showPicker()
                                    } else {
                                        imageURL = nil
                                    }
                                }) {
                                    Text(imageURL == nil ? "Select custom image/file" : imageURL!.lastPathComponent)
                                        .padding(.horizontal, 16)
                                        .frame(maxWidth: .infinity)
//                                        .background(Color(UIColor.secondarySystemFill))
//                                        .cornerRadius(8)
                                        .sheet(isPresented: $showingImagePicker) {
                                            ImagePickerView(imageURL: $imageURL)
                                        }
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                
                                Button(action: {
                                    toggleTrollButtonTapped()
                                }) {
                                    Text(!trollController.isRunning ? "Start trolling" : "Stop trolling")
                                        .padding(.horizontal, 16)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.bordered)
                                .tint(.accentColor)
                                .controlSize(.large)
                            }
                            .modifier(AutoPad())
//                            .padding(.bottom, hasHomeIndicator ? 69 : 42) // TODO: Test on non-notched devices
                            .padding()
                        }
                    }
                }
                .navigationTitle("AirTroller")
            }
            .onAppear {
                // Start searching nodes
                if !AirTrollerStatus.shared.isRunning {
                    trollController.startBrowser()
                }
            }
//            .onDisappear {
//                trollController.stopBrowser() // bruh
//            }
            .onChange(of: rechargeDuration) { newValue in
                trollController.rechargeDuration = newValue
            }
            .onChange(of: trollController.isRunning) {new in
                withAnimation {
                    AirTrollerStatus.shared.isRunning = new
                }
            }
            
        }
        
        // shows a privacy req dialog if needed
        func showPicker() {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    // show picker if authorized
                    showingImagePicker = status == .authorized
                }
            }
        }
        
        func toggleTrollButtonTapped() {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred() // mmm
            
            guard selectedPeople.values.filter({ $0 == true }).count > 0 else {
                UIApplication.shared.alert(title: "No people selected", body: "Select users by tapping on them.")
                return
            }
            
            if !trollController.isRunning {
                UIApplication.shared.confirmAlert(title: "\(UIDevice.current.name)", body: "This is the current name of this device and the name people will see when receiving an AirDrop. Are you sure you want to continue?", onOK: {
                    if let imageURL = imageURL {
                        trollController.sharedURL = imageURL
                    }
                    trollController.startTrolling(shouldTrollHandler: { person in
                        return selectedPeople[person.node] ?? false // troll only selected people
                    }, eventHandler: { event in
                        switch event {
                        case .operationEvent(let event1):
                            if event1 == .canceled || event1 == .finished || event1 == .blocked {
                                totalAirDrops += 1
                                Haptic.shared.play(.light)
                            }
                        case .cancelled:
                            totalAirDrops += 1
                            Haptic.shared.play(.light)
                        }
                    }) // start trolling :troll:
                    trollController.isRunning.toggle()
                }, noCancel: false)
            } else {
                trollController.stopTrollings()
                trollController.isRunning.toggle()
            }
        }
        
        struct PersonView: View {
            @State var person: TrollController.Person
            @Binding var selected: Bool?
            @EnvironmentObject var trollController: TrollController
            
            var body: some View {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    if selected == nil { selected = false }
                    selected?.toggle()
                    print("selected", selected!)
                }) {
                    VStack {
                        ZStack {
                            Image((selected ?? false) ? "TrolledPerson" : "NonTrolledPerson")
                        }
                        Text(person.displayName ?? "Unknown")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.init(UIColor.label))
                    }
                }
                .disabled(trollController.isRunning)
            }
        }
}

#Preview {
    AirTrollerView()
}
