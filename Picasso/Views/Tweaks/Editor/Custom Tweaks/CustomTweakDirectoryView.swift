//
//  CustomTweakDirectoryView.swift
//  Picasso
//
//  Created by sourcelocation on 06/08/2023.
//

import SwiftUI
import NavigationBackport

struct CustomTweakDirectoryView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedURL: String
    var currentURL: URL
    @State var contents: [URL]?
    @State var error: String?
    
    @State var showingManualPathEntry = false
    
    @State var orig: UInt64? = nil
    
    let fm: FileManager = .default
    
    init(selectedURL: Binding<String>, currentURL: URL) {
        self._selectedURL = selectedURL
        self.currentURL = currentURL
        
        do {
            var contentsTemp: [URL] = []
            if !ExploitKit.shared.isTrollStore && ExploitKit.shared.selectedExploit == .kfd {
                let mount = try ExploitKit.shared.GetContentsOfDirectory(currentURL)
                orig = mount.orig_to_v_data
                contentsTemp = mount.contents
            } else {
                contentsTemp = try fm.contentsOfDirectory(at: currentURL, includingPropertiesForKeys: nil)
            }
            // sort all files first, then all directories
            contents = contentsTemp.sorted(by: { (a, b) -> Bool in
                let isDirA = a.hasDirectoryPath
                let isDirB = b.hasDirectoryPath
                if isDirA == isDirB {
                    return a.lastPathComponent < b.lastPathComponent
                } else {
                    return !isDirA && isDirB
                }
            })
            print(contents)
            self.error = nil
        } catch {
            self.error = error.localizedDescription
            contents = nil
        }
    }
    
    var body: some View {
        VStack {
            if let error = error {
                Label("\(error)", systemImage: "exclamationmark.octagon")
                    .foregroundColor(Color(UIColor.systemRed))
                    .padding(3)
            } else if let contents = contents {
                List {
                    Section {
                        ForEach(contents, id: \.path) { item in
                            let isDir = item.isDirectory
                            var isSymLink = item.isSymLink
                            
                            if isDir || isSymLink {
                                NavigationLink {
                                    CustomTweakDirectoryView(selectedURL: $selectedURL, currentURL: item)
                                } label: {
                                    RowView(item: item, isDir: true)
                                }
                            } else {
                                Button {
                                    selectedURL = item.path
                                    dismiss()
                                } label: {
                                    RowView(item: item, isDir: false)
                                }
                            }
                        }
                    } footer: {
                        HStack {
                            Text("\(contents.count) item\(contents.count == 1 ? "" : "s")") // wild concat
                            Spacer()
                            Image(systemName: fm.isWritableFile(atPath: currentURL.path) ? "lock.open" : "lock") // filza reference???
                        }
                    }
                }
                .onAppear {
                    print(currentURL)
                }
            }
        }
        .navigationTitle(currentURL.path == "/" ? "Browse" : currentURL.lastPathComponent)
        .onDisappear {
            if orig != nil { // unmount folder only if it already is mounted
                try? KFD.unmountFileAtURL(mountURL: currentURL, orig_to_v_data: orig!)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingManualPathEntry = true
                } label: { Image(systemName: "pencil") }
            }
        }
        .alert("Enter path manually", isPresented: $showingManualPathEntry) {
            TextField("/path/to/file", text: $selectedURL)
            Button("Set") {}
            Button("Cancel", role: .cancel) {
                selectedURL = "/"
            }
        } message: {
            Text("For the tweak to be saved a name must be given")
        }
    }
    
    struct RowView: View {
        var item: URL
        var isDir: Bool
        
        var body: some View {
            HStack {
                if isDir {
                    Image(systemName: "folder")
                } else {
                    Image(systemName: "doc")
                        .foregroundColor(.accentColor)
                }
                Text(item.lastPathComponent)
            }
        }
    }
    
    func getContentsAutomatic(_ at: URL) throws -> (mountPoint: URL, contents: [URL], orig_to_v_data: UInt64?) {
        let fm: FileManager = .default
        print("[SkunkFM] attempting filemanager")
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
        return (at, contents, nil)
    }
}

//struct CustomTweakDirectoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomTweakDirectoryView(url: $url)
//    }
//}
