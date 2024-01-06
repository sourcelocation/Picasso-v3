//
//  TweakCompileReview.swift
//  Picasso
//
//  Created by sourcelocation on 06/08/2023.
//

import SwiftUI
import CachedAsyncImage
import URLBackport

struct TweakCompileReviewView: View {
    
    @ObservedObject var package: LocalPackage
    
    @AppStorage("authorName") var authorName = "Unknown"
    
    @State var disableExport = false
    
    var body: some View {
        Form {
            // List all editable fields, and allow the user to edit them
            Section {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Name", text: $package.info.name)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Author")
                    Spacer()
                    TextField("Author", text: $authorName)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Version")
                    Spacer()
                    TextField("Version", text: $package.info.version)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Bundle ID")
                    Spacer()
                    TextField("Bundle ID", text: $package.info.bundleID)
                        .textInputAutocapitalization(.none)
                        .multilineTextAlignment(.trailing)
                        .onAppear {
                            disableExport = checkBundleID(package.info.bundleID)
                        }
                        .onChange(of: package.info.bundleID) {bundleID in
                            disableExport = checkBundleID(bundleID)
                        }
                }


//                TextField("Icon URL", text: $package.info.iconURL)
//                CachedAsyncImage(url: Binding($package.iconURL)!.wrappedValue) { image in
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 54, height: 54)
//                        .cornerRadius(16)
//                } placeholder: {
//                    ProgressView()
//                        .frame(width: 54, height: 54)
//                        .cornerRadius(16)
//                }
            }
            
            if disableExport {
                Section(footer: Label("A package with the specified Bundle ID already exists.", systemImage: "exclamationmark.octagon").foregroundColor(Color(UIColor.systemRed))){}
            }

            Section {
                Button(action: {
                    Haptic.shared.play(.soft)
                    do {
                        package.info.author = authorName
                        if package.url == nil {
                            // generated using a template
                            package.url = URL.backport.temporaryDirectory.appendingPathComponent(package.info.bundleID)
                        }
                        package.save(to: package.url!)
                        try TweakManager.shared.installLocalPackage(package)
                        Haptic.shared.notify(.success)
                        UIApplication.shared.alert(title: "Installed successfully!", body: "The tweak has been installed successfully. Changes will now be applied when button \"Apply\" is pressed on the Home tab, or when background refresh triggers.")
                    } catch {
                        Haptic.shared.notify(.error)
                        UIApplication.shared.alert(body: "\(error.localizedDescription)")
                    }
                }, label: {
                  Label("Save and Install", systemImage: "square.and.arrow.down")
                })
                .disabled(disableExport)
            }
        }
        .navigationTitle("Compile Tweak")
    }
     
    /// Returns false if bundle id already exists in local registry.
    func checkBundleID (_ id: String) -> Bool {
        let packages = TweakManager.shared.installedPackages
        for package in packages {
            if package.info.bundleID == id {
                return true
            }
        }
        return false
    }
}

//struct TweakCompileReview_Previews: PreviewProvider {
//    static var previews: some View {
//        TweakCompileReviewView()
//    }
//}
