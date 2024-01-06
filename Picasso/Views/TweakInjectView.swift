//
//  TweakInjectView.swift
//  Picasso
//
//  Created by sourcelocation on 06/12/2023.
//

import SwiftUI

struct TweakInjectView: View {
    
    @State var pid: String = ""
    @State var showingFilePicker = false
    @State var tweakData: Data?
    @State var tweakName = ""
    
    var body: some View {
//        NavigationView {
            VStack {
                TextField("PID", text: $pid)
                Button("Select tweak .dylib") {
                    showingFilePicker = true
                }
                .buttonStyle(.bordered)
                Text(tweakName)
                
                Button("Inject!") {
                    tweakInject()
                }
                .buttonStyle(.bordered)
                .tint(.accentColor)
            }
            .navigationTitle("Tweak Inject")
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker(types: [ .folder ], allowsMultipleSelection: false) { urls in
                    for url in urls {
                        defer { url.stopAccessingSecurityScopedResource() }
                        do {
                            let _ = url.startAccessingSecurityScopedResource()
                            tweakData = try Data(contentsOf: url)
                            tweakName = url.lastPathComponent
                        } catch {
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    }
                }
            }
//        }
    }
    
    func tweakInject() {
        do {
            try TrollStoreRootHelper.refreshAppRegistration(from: URL(fileURLWithPath: "/var/containers/Bundle/Application/81D0F89C-F283-4F2F-9316-A435DC5852D7/"))
        } catch {
            UIApplication.shared.alert(body: error.localizedDescription)
        }
    }
}

#Preview {
    TweakInjectView()
}
