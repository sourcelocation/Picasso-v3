//
//  CustomTweakAssetsViewer.swift
//  Picasso
//
//  Created by sourcelocation on 06/08/2023.
//

import SwiftUI

struct CustomTweakAssetsPicker: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var package: LocalPackage
    @Binding var selectedPath: String
    
    @State var urls: [(URL, String)] = []
    
    var body: some View {
        List { // TODO: grid
            if urls.isEmpty {
                Text("No files imported. Use the import button in the toolbar.")
            } else {
                ForEach(urls, id: \.0.path) { url in
                    Button {
                        selectedPath = "assets/" + url.0.lastPathComponent
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "doc")
                            VStack {
                                Text(url.0.lastPathComponent)
                                Text(url.1)
                            }
                        }
                    }
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
        try? FileManager.default.createDirectory(at: package.url!.appendingPathComponent("assets"), withIntermediateDirectories: true, attributes: nil)
        urls = []
        
        let url = package.url!.appendingPathComponent("assets")
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
