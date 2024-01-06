//
//  ThemeApplyProgressView.swift
//  Picasso
//
//  Created by sourcelocation on 08/12/2023.
//

import SwiftUI
import CachedAsyncImage

struct ThemeApplyProgressView: View {
    
    private let startTime =  Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let images = ["safari", "folder", "gear", "message", "photo", "envelope", "camera", "calendar", "video", "map", "note.text", "waveform"]
    
    var memePrefix = "https://bomberfish.ca/PicassoMemes/"
    var memes = [
        "1.webp",
        "2.webp",
        "3.webp",
        "4.webp",
        "5.webp",
        "6.webp",
        "7.webp",
        "8.webp",
        "9.jpeg",
        "10.jpeg",
        "11.jpeg",
        "12.png",
        "13.png",
        "14.webp"
    ]
    
    @State var currentMeme: String = ""
    
    @State var fullError: String = ""
    
    var revert: Bool
    
    @StateObject var themeManager = ThemeManager.shared
    @AppStorage("agreedToAnalytics") var agreedToAnalytics = true
    
    
    @State var finished = false
    @State var finishedWithErrors = false
    
    @State var animationI: Int = 0
    @State var memeI: Int = 0
    
    @State var timerI: String = ""
    
    @State var progress: Double = 0
    @State var statusMessage: String = "Starting"
    
    @AppStorage("enableMemez") var memesOn: Bool = false
    @State var memeImage: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
//            Text(timerI)
//                .onReceive(timer) { input in
//                    timerI = "\(input), \(Int(startTime - input) * -1)"
//                }
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: finished ? .infinity : 16)
                    .frame(width: 64, height: 64)
                    .foregroundColor(finished && finishedWithErrors ? Color(UIColor.systemYellow) : .accentColor)
                    .opacity(0.3)
                Image(systemName: finished ? ( finishedWithErrors ? "exclamationmark.triangle" : "checkmark") : images[animationI])
                    .imageScale(.large)
                    .font(.system(size: 20))
                    .foregroundColor(finished && finishedWithErrors ? Color(UIColor.systemYellow) : .accentColor)
            }
            
            VStack(spacing: 6) {
                Text(finished ? (finishedWithErrors ? "Finished, with some errors." : "Finished.") : "Applying...")
                    .font(.title.bold())
                
                if !finished {
                    Text("This process shouldn't take longer than a couple of seconds")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            if !finished {
                VStack {
                    HStack {
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                        Text("\(Int(progress))%")
                            .padding(.leading, 4)
                    }
                    .padding(.horizontal, 32)
                    
                    Text("\(statusMessage)")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack {
                if finished && finishedWithErrors {
                    ScrollView(showsIndicators: true) {
                        Text(fullError)
                            .font(.system(.caption, design: .monospaced))
                            .padding(10)
                    }
                    .frame(height: 100)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal)
                
            if !finished {
                if !memesOn {
                    Spacer()
                } else {
                    CachedAsyncImage(url: URL(string: memePrefix + currentMeme)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(.thinMaterial)
                            .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                    }
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                    .frame(maxHeight: 256)
                    .onAppear {
                        currentMeme = memes[0]
                    }
                    .onReceive(timer) { input in
                        print(input)
                        if (Int(startTime - input) * -1) % 8 == 1 {
                            withAnimation {
                                if memeI == memes.count - 1 {
                                    currentMeme = memes[0]
                                    memeI = 0
                                } else {
                                    memeI += 1
                                    currentMeme = memes[memeI]
                                }
                            }
                        }
                    }
                }
                HStack {
                    Spacer()
                    Text("Memes")
                    Toggle("Enable Memes", isOn: $memesOn)
                        .labelsHidden()
                        .tint(.accentColor)
                    Spacer()
                }
            } else {
                VStack(alignment: .leading) {
                    Label(title: { Text("Cleanup required").font(.headline) }, icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                    })
                    Text("After restarting, please re-enter the app for OpenPicasso to fix crashes of apps.")
                }
                .padding()
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(10)
                .transition(.opacity)
                .padding(.horizontal)
                
                VStack(alignment: .center) {
                    HStack {
                        Label(title: { Text("Compression").font(.headline) }, icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                        })
                        Spacer()
                    }
                    Text("Some icons may appear compressed. This is a limitation of exploits used in OpenPicasso.")
                    Image("compression-alert")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80)
                }
                .padding()
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(10)
                .transition(.opacity)
                .padding(.horizontal)
                
                Button {
                    restart()
                } label: {
                    Text("Restart (Respring)")
                        .padding(4)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.accentColor)
                .padding(.horizontal)
                Spacer()
                
            }
            
        }
        .onChange(of: memesOn) { isOn in
            //            if isOn, !self.memesOn {
            memeI = .random(in: 0...(memes.count-1))
            //            }
        }
        .onReceive(timer) { input in
            withAnimation {
                animationI += 1
                
                if animationI + 1 > images.count {
                    animationI = 0
                }
            }
        }
        .onAppear {
            apply()
        }
        .interactiveDismissDisabled()
    }
    
    func apply() {
        DispatchQueue.global().async {
            if revert {
                for theme in themeManager.themes {
                    theme.isSelected = false
                }
            }
            do {
                if SourcedRepoFetcher.shared.accountPurchases.contains("picasso-themes"), agreedToAnalytics {
                    Task {
                        try await SourcedRepoFetcher.shared.sendApplyLogs(themes: themeManager.themes.compactMap { $0.isSelected ? $0 : nil }.map { [$0.name, String($0.iconCount), $0.sourcedRepoTheme ? "picasso" : "imported" ] })
                    }
                }
                try themeManager.apply { (string, progress) in
                    DispatchQueue.main.async {
                        self.statusMessage = string
                        self.progress = progress
                    }
                    print(string)
                }
                Haptic.shared.notify(.success)
            } catch {
                finishedWithErrors = true
                DispatchQueue.main.async {
                    Haptic.shared.notify(.success)
//                    UIApplication.shared.confirmAlert(title: "Success, but some errors occurred", body: "Errors occured while applying icons for these applications:\n\n\(error.localizedDescription)",  confirmTitle: "Continue", onOK: {}, noCancel: true)
                    fullError = error.localizedDescription
                    print(error)
                }
            }
            withAnimation {
//                finished = true
            }
        }
    }
    func restart() {
        removeIconCache()
        respring()
    }
}

#Preview {
    ThemeApplyProgressView(revert: false)
}
