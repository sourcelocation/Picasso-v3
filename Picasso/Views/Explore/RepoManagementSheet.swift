//
//  RepoManagementSheet.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-05.
//

import SwiftUI
import CachedAsyncImage
import NavigationBackport

struct RepoManagementSheet: View {
    @StateObject var tweakRepoFetcher = TweakRepoFetcher.shared
    
    @State var showingURLEntryAlert = false
    @State var enteredManifestURL = ""
    
    let recommendedRepos = [
        "https://bomberfish.ca/PicassoRepos/Essentials/manifest.json",
        "https://raw.githubusercontent.com/sourcelocation/Picasso-test-repo/main/manifest.json"
    ]
    
    @State var currentRecommends: [String] = []
    
    init() {
        updateRecommends()
    }
    
    var body: some View {
        Navigator {
            List {
                Section {
                    ForEach(tweakRepoFetcher.repos, id: \.?.id) { repo in
                        HStack {
                            if let repo {
                                CachedAsyncImage(url: repo.iconURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 54, height: 54)
                                        .cornerRadius(16)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 54, height: 54)
                                        .cornerRadius(16)
                                }
                                VStack(alignment: .leading) {
                                    Text(repo.name)
                                        .font(.body.weight(.bold))
                                        .truncationMode(.tail)
                                    Text(repo.description)
                                        .font(.caption)
                                        .truncationMode(.tail)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Text("Invalid repo")
                                    .foregroundColor(Color(UIColor.systemRed))
                            }
                        }
                    }
                    .onDelete { index in
                        tweakRepoFetcher.manifestURLs.remove(atOffsets: index)
                        UIApplication.shared.alert(title: "Refreshing...", body: "")
                        Task {
                            try await tweakRepoFetcher.updateRepos()
                            UIApplication.shared.dismissAlert(animated: true)
                        }
                        updateRecommends()
                    }
                }
                
                if !(currentRecommends.isEmpty) {
                    Section("Recommended Repos") {
                        ForEach($currentRecommends, id: \.self) {repo in
                            @State var loading: Bool = true
                            let url = URL(string: repo.wrappedValue)!
                            var parsedRepo: Repo? = nil
                            Group {
                                if parsedRepo != nil {
                                    CachedAsyncImage(url: parsedRepo!.iconURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 54, height: 54)
                                            .cornerRadius(16)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 54, height: 54)
                                            .cornerRadius(16)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(parsedRepo!.name)
                                            .font(.body.weight(.bold))
                                            .truncationMode(.tail)
                                        Text(parsedRepo!.description)
                                            .font(.caption)
                                            .truncationMode(.tail)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    Text("Loading \(repo.wrappedValue)...")
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                            }
                            .task(priority: .userInitiated) {
                                do {
                                    let parsedManifest: RepoManifest = try await tweakRepoFetcher.parseManifest(url)
                                    print("Parsed repo \(parsedManifest.name)")
                                    let parsedRepo2: Repo = .init(manifest: parsedManifest)
                                    print("Loaded and parsed repo \(parsedRepo2.name)")
                                    parsedRepo = parsedRepo2
                                    print("Loaded and parsed repo \(parsedRepo?.name ?? "nil")")
                                } catch {
                                    print(error)
                                    parsedRepo = nil
                                }
                            }
                        }
                    }
                    .headerProminence(.increased)
                }
            }
            .onAppear {
                updateRecommends()
            }
            .alert("Enter manifest URL of repo", isPresented: $showingURLEntryAlert) {
                TextField("", text: $enteredManifestURL)
                Button("Add") {
                    tweakRepoFetcher.manifestURLs.append(enteredManifestURL)
                    UIApplication.shared.alert(title: "Refreshing...", body: "")
                    Task {
                        try await tweakRepoFetcher.updateRepos()
                        UIApplication.shared.dismissAlert(animated: true)
                    }
                }
                .tint(.accentColor)
                Button("Cancel", role: .cancel) {
                    enteredManifestURL = ""
                }
                .tint(.accentColor)
            }
            .toolbar {
                HStack(alignment: .center) {
                    Spacer()
                    Button(action: {
                        showingURLEntryAlert = true
                    }, label: {
                        Label("", systemImage: "plus")
                    })
                }
            }
            .navigationTitle("Manage Repos")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func updateRecommends() {
        for repo in recommendedRepos {
            if !(tweakRepoFetcher.manifestURLs.contains(where: { $0 == repo })) {
                currentRecommends.append(repo)
            }
        }
    }
}

//#Preview {
//    RepoManagementSheet()
//}
