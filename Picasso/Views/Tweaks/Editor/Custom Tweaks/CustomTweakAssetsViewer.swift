//
//  CustomTweakAssetsViewer.swift
//  Picasso
//
//  Created by sourcelocation on 06/08/2023.
//

import SwiftUI

struct CustomTweakAssetsViewer: View {
    @ObservedObject var tweak: LocalPackage
    
    @State var showingFilePicker = false
    @State var urls: [(URL, String)] = []
    
    var body: some View {
        List { // TODO: grid
            ForEach(urls, id: \.0.path) { url in
                HStack {
                    Image(systemName: "doc")
                    VStack {
                        Text(url.0.lastPathComponent)
                        Text(url.1)
                    }
                }
            }
            .onDelete { offsets in
                for offset in offsets {
                    do {
                        try FileManager.default.removeItem(at: urls[offset].0)
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                }
                do {
                    try updateURLs()
                } catch {
                    UIApplication.shared.alert(body: error.localizedDescription)
                }
            }
            Button("add") {
                showingFilePicker = true
            }
        }
        .sheet(isPresented: $showingFilePicker) {
            DocumentPicker(types: [ .item ], allowsMultipleSelection: false) { urls in
                for url in urls {
                    defer { url.stopAccessingSecurityScopedResource() }
                    do {
                        guard url.startAccessingSecurityScopedResource() else { throw "No permission" }
                        try FileManager.default.copyItem(at: url, to: tweak.url!.appendingPathComponent("assets").appendingPathComponent(url.lastPathComponent))
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                }
                do {
                    try updateURLs()
                } catch {
                    UIApplication.shared.alert(body: error.localizedDescription)
                }
            }
        }
        .onAppear {
            do {
                try updateURLs()
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
    }
    
    func updateURLs() throws {
        try? FileManager.default.createDirectory(at: tweak.url!.appendingPathComponent("assets"), withIntermediateDirectories: true, attributes: nil)
        urls = []
        
        let url = tweak.url!.appendingPathComponent("assets")
        // get all files in directory
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        
        for file in contents {
            // get file size
            let size = try FileManager.default.attributesOfItem(atPath: file.path)[.size] as? Int ?? 0
            // format size
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useAll]
            formatter.countStyle = .file
            let sizeString = formatter.string(fromByteCount: Int64(size))

            urls.append((file, sizeString))
        }
    }
}
