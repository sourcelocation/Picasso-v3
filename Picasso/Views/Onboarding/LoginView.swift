//
//  LoginView.swift
//  Evyrest
//
//  Created by exerhythm on 30.11.2022.
//

import SwiftUI
import NavigationBackport
import FluidGradient


struct LoginView: View {
      
    @EnvironmentObject var navigator: PathNavigator
    @Environment(\.openURL) var openURL
    
    var onLogin: () -> ()
    
    @State var username = ""
    @State var password = ""
    
    @StateObject var sourcedRepoFetcher = SourcedRepoFetcher.shared
    
    @State var loginInProgress = false
    
    var body: some View {
        GeometryReader { geometry in
//            Navigator {
                ZStack {
                    OnboardingBGView()
                    VStack {
                        Spacer()
                        Image(systemName: "person.badge.key")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 75)
                            .padding(.bottom, 8)
                            .foregroundColor(.accentColor)
                        
                        //                        .frame(width: .max)
                        //                }
//                        HStack {
//                            Image(systemName: "person.badge.key")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .foregroundColor(.accentColor)
//                                .frame(height: 24)
//                            Text("Please log in into your Sourced Repo account to continue.")
//                                .padding(10)
//                        }
                        Text("Log in")
                            .font(.system(size: 28, weight: .bold))
                        TextField("Email", text: $username)
                            .modifier(fancyInputViewModifier())
                            .padding(.top, 2)
                            .textInputAutocapitalization(.never)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                        SecureField("Password", text: $password)
                            .modifier(fancyInputViewModifier())
                            .autocorrectionDisabled(true)
                            .textContentType(.password)
                        
                        Spacer()
                        
                        Button(action: {
                            openURL(.init(string: "https://repo.sourceloc.net/skill-issue")!)
                        }, label: {
                            Label("Forgot Password", systemImage: "person.fill.questionmark")
                        })
                        .padding(.vertical, 8)
                        
                        Button(action: {
                            Haptic.shared.play(.soft)
                            Task {
                                do {
                                    loginInProgress = true
                                    try await sourcedRepoFetcher.login(username: username, password: password)
                                    loginInProgress = false
                                    onLogin()
                                } catch {
                                    DispatchQueue.main.async {
                                        loginInProgress = false
                                        UIApplication.shared.alert(body: "\(error.localizedDescription)")
                                    }
                                }
                            }
                        }) {
                            Group{
                                if loginInProgress {
                                    ProgressView()
                                } else {
                                    Text("Log in")
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .font(.body.weight(.bold))
                            .background(Color.accentColor)
                            .foregroundColor(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                        }
                        
                        NavigationLink("Sign up", destination: SignupView(onLogin: onLogin))
                    }
                    .disabled(loginInProgress)
                    .padding()
                    .padding([.horizontal], 25)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.thickMaterial)
                }
            }
            .interactiveDismissDisabled()
//        }
    }
        
}

struct SignupView: View {
    
    @Environment(\.openURL) var openURL
    
    var onLogin: () -> ()
    
    @State var username = ""
    @State var password = ""
    @State var passwordConfirm = ""
    
    @StateObject var sourcedRepoFetcher = SourcedRepoFetcher.shared
    
    @State var loginInProgress = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                OnboardingBGView()
                VStack {
                    Spacer()
                    Image(systemName: "person.badge.plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 75)
                        .padding(.bottom, 8)
                        .foregroundColor(.accentColor)
                    Text("Sign Up")
                        .font(.system(size: 28, weight: .bold))
                    TextField("Email", text: $username)
                        .modifier(fancyInputViewModifier())
                        .padding(.top, 2)
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                    SecureField("Password", text: $password)
                        .modifier(fancyInputViewModifier())
                        .autocorrectionDisabled(true)
                        .textContentType(.password)
                    SecureField("Confirm Password", text: $passwordConfirm)
                        .modifier(fancyInputViewModifier())
                        .autocorrectionDisabled(true)
                        .textContentType(.password)
                        .padding(.bottom, 100)
                    
                    Spacer()
                    
                }
                .overlay { // i love swiftui.
                    VStack {
                        Spacer()
                        Button(action: {
                            Haptic.shared.play(.soft)
                            Task {
                                do {
                                    loginInProgress = true
                                    try await sourcedRepoFetcher.signup(username: username, password: password)
                                    loginInProgress = false
                                    onLogin()
                                } catch {
                                    DispatchQueue.main.async {
                                        loginInProgress = false
                                        UIApplication.shared.alert(body: "\(error.localizedDescription)")
                                    }
                                }
                            }
                        }) {
                            Group{
                                if loginInProgress {
                                    ProgressView()
                                } else {
                                    Text("Sign up")
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .font(.body.weight(.bold))
                            .background(Color.accentColor)
                            .foregroundColor(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .disabled(loginInProgress || username.isEmpty || password != passwordConfirm)
                        }
                    }
                }
                .disabled(loginInProgress)
                .padding()
                .padding([.horizontal], 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.thickMaterial)
            }
            .interactiveDismissDisabled()
        }
    }
        
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Navigator {
            LoginView(onLogin: {UIApplication.shared.alert(title: "Success", body: "Login Succeeded!")})
        }
    }
}
