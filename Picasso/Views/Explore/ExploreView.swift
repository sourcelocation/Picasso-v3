//
//  ExploreView.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-04.
//

import SwiftUI
import CachedAsyncImage
import NavigationBackport

struct ExploreViewWrapper: View {
    var body: some View {
        Navigator {
            ExploreView()
                .navigationTitle("Explore")
        }
    }
}

struct ExploreView: View {
    
    @StateObject var tweakManager = TweakManager.shared
    
    @State var allPackages: [RepoPackage] = []
    
    @State var packages: [RepoPackage] = []
    
    @State var searchTerm: String = ""
    
    @State var showSheet: Bool = false
    
    var body: some View {
            List {
                Section {
                    HStack {
                        Button {
                            showSheet = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Image(systemName: "doc.plaintext.fill")
                                    Text("Manage Repos")
                                }
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                        Button {
                            print("trolled")
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Image(systemName: "newspaper.fill")
                                    Text("New")
                                }
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0 ))
                .listRowBackground(Color.clear)
                
                Section(header: Text("Featured").foregroundColor(.primary).font(.title2.weight(.bold)).textCase(nil)) { // is this what god wanted
                    ForEach($packages, id: \.bundleID) { package in
                        NavigationLink {
                            TweakDepictionView(package: package)
                        } label: {
                            HStack {
                                HStack(spacing: 16) {
                                    CachedAsyncImage(url: package.iconURL.wrappedValue) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 54, height: 54)
                                            .cornerRadius(14)
                                    } placeholder: {
                                        ZStack(alignment: .center) {
                                            Rectangle()
                                                .background(.thinMaterial)
                                                .frame(width: 54, height: 54)
                                            ProgressView()
                                                .font(.title3)
                                        }
                                        .cornerRadius(14)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(package.name.wrappedValue)
                                            .font(.headline)
                                        Text("\(package.version.wrappedValue) • \(package.author.wrappedValue) ")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    Haptic.shared.play(.light)
                                    Task {
                                        do {
                                            try await tweakManager.installPackage(package.wrappedValue)
                                            Haptic.shared.notify(.success)
                                            UIApplication.shared.alert(title: "Success", body: "Tweak has been successfully installed.")
                                        } catch {
                                            Haptic.shared.notify(.error)
                                            UIApplication.shared.alert(body: "\(error.localizedDescription)")
                                        }
                                    }
                                }, label: {
                                    Text("Get")
                                        .bold()
                                        .foregroundColor(.accentColor)
                                        .padding(6)
                                        .padding(.horizontal, 8)
                                        .background(Color.accentColor.opacity(0.2))
                                        .cornerRadius(50)
                                })
//                                Image(systemName: "chevron.right") //nfr
//                                    .foregroundColor(.secondary)
                            }
                        }
                        .listRowInsets(.init(top: 10, leading: 12, bottom: 10, trailing: 20))
                    }
                }
            }
            .modifier(AutoPad())
            .sheet(isPresented: $showSheet, onDismiss: {showSheet = false}, content: {RepoManagementSheet()})
            .onAppear {
                refreshRepos()
            }
            .refreshable {
                refreshRepos()
            }
            .searchable(text: $searchTerm)
            // TODO: Search scopes per repo?
            .onChange(of: searchTerm) {query in // TODO: Fuzzy search somehow?
                if query == "" {
                    packages = allPackages
                } else {
                    packages = allPackages.filter { $0.name.lowercased().contains(query) }
                }
            }
    }
    
    func refreshRepos() {
        Task {
            do {
                try await tweakManager.fetcher.updateRepos()
            } catch {
                UIApplication.shared.alert(title: "Errors occurred while refreshing repos", body: "\(error.localizedDescription)")
            }
            let repos = tweakManager.fetcher.repos.compactMap({ $0 })
            allPackages = repos.flatMap({ $0.packages })
            packages = allPackages
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}

