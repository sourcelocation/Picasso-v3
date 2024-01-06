//
//  AccountPage.swift
//  Picasso
//
//  Created by sourcelocation on 04/08/2023.
//

import SwiftUI
import NavigationBackport

struct AccountPage: View {
    
    @StateObject var sourcedRepoFetcher = SourcedRepoFetcher.shared
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Navigator {
            List {
                Section(header: Label("Account", systemImage: "person")) {
                    InfoCell(title: "Username", value: "@\(sourcedRepoFetcher.username ?? "Not Logged In")")
                    InfoCell(title: "Email", value: "\(sourcedRepoFetcher.email ?? "Not Logged In")")
                }
                Section {
                    Button {
                        openURL(.init(string: "https://repo.sourceloc.net/account/general")!)
                    } label: {
                        Label("Change password", systemImage: "person.badge.key")
                            .buttonStyle(.bordered)
                        
                    }
                    Button {
                        Haptic.shared.play(.soft)
                        sourcedRepoFetcher.logout()
                        dismiss()
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                        
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        CloseButton()
                    })
                })
            }
        }
        
//        .alert("Change password", isPresented: $showingChangePasswordAlert) {
//            SecureField("New password", text: $newPasswordInput)
//            SecureField("Repeat password", text: $repeatPasswordInput)
//            Button("Cancel", role: .cancel) {
//                showingChangePasswordAlert = false
//            }
//            Button("Change password") {
//                showingChangePasswordAlert = false
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    Task {
//                        do {
//                            try await sourcedRepoFetcher.changePassword(to: newPasswordInput)
//                        } catch {
//                            UIApplication.shared.alert(body: "There was an error with changing password. \(error.localizedDescription)")
//                        }
//                    }
//                }
//            }
//            .disabled(newPasswordInput != repeatPasswordInput || newPasswordInput.count < 8)
//        }
    }
}

struct AccountPage_Previews: PreviewProvider {
    static var previews: some View {
        AccountPage()
    }
}
