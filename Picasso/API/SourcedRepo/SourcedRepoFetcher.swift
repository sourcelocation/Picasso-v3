//
//  SourcedRepoAPI.swift
//  Evyrest
//
//  Created by exerhythm on 30.11.2022.
//

import SwiftUI


/// Sourced Repo fetcher
class SourcedRepoFetcher: ObservableObject {
    
    static var shared = SourcedRepoFetcher()
    
    var session = URLSession.shared
    
    var currentServerHost: String?
    
    
    @Published var showLogin = true
    
    @AppStorage("userToken") var userToken: String?
    @AppStorage("username") var username: String?
    @AppStorage("email") var email: String?
    @AppStorage("accountPurchases") var accountPurchases: [String] = []
    
    init() {
        self.showLogin = userToken == nil
    }
    
    
    public func signup(username: String, password: String) async throws {
        // TODO: implement signup through account endpoint
//        throw "SourcedRepoFetcher.signup() not implemented" // idk if this works yet ill have to run it by source sometime
        
        var request = URLRequest(url: .sourcedRepo)
        request.httpMethod = "POST"
        let authBase64 = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        request.addValue("Basic \(authBase64)", forHTTPHeaderField: "Authorization")
        
        let (_, statusCode) = try await requestData(request: request, endpoint: "account")
        
        if statusCode == 409 {
            throw "Username or email is already registered. (409)"
        }
        
        guard statusCode == 200 else { throw "Unable to create user. (\(statusCode))" }
    }
    
    /// Logs into Sourced and, if successful, returns a token
    public func login(username: String, password: String) async throws {
        var request = URLRequest(url: .sourcedRepo)
        request.httpMethod = "POST"
        let authBase64 = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        request.addValue("Basic \(authBase64)", forHTTPHeaderField: "Authorization")
        
        let (data, statusCode) = try await requestData(request: request, endpoint: "account/login")
        
        
        guard statusCode == 200 else { throw "Invalid email or password. (\(statusCode))" }
        let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String: Any]
        guard let token = (json["token"] as? [String: Any])?["value"] as? String else { throw "Couldn't parse token. Error code 2" }
        guard let username = (json["user"] as? [String: Any])?["username"] as? String else { throw "Couldn't parse user. Error code 3" }
        guard let email = (json["user"] as? [String: Any])?["email"] as? String else { throw "Couldn't parse email. Error code 4" }
        
        guard let purchases = (json["user"] as? [String: Any])?["purchases"] as? [String] else { throw "Couldn't parse purchases. Error code 5" }
        DispatchQueue.main.async {
            self.userToken = token
            self.username = username
            UserDefaults.standard.synchronize()
            self.email = email
            self.accountPurchases = purchases
            self.showLogin = false
        }
    }
    
    /// Gets account, contains purchases
    public func purchases() async throws -> [String] {
        guard let userToken = userToken else { throw "Not logged in." }
        var request = URLRequest(url: .sourcedRepo)
        request.httpMethod = "GET"
        request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        let (data, statusCode) = try await requestData(request: request, endpoint: "account/purchases")
        switch statusCode {
        case 208, 200: break
        default:
            throw "Something went wrong while changing the password. (\(statusCode))"
        }
        let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String]
        return json
    }
    
    
    public func changePassword(to newPass: String) async throws {
        guard let userToken = userToken else { throw "Not logged in." }
        var request = URLRequest(url: .sourcedRepo)
        request.httpMethod = "POST"
        request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        
        let json: [String: Any] = ["newPassword": newPass]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        let (_, statusCode) = try await requestData(request: request, endpoint: "account/changePasswordaccount")
        print("[SourcedRepoFetcher] \(statusCode)")
        switch statusCode {
        case 208, 200: break
        default:
            throw "Something went wrong while changing the password. (\(statusCode))"
        }
    }
    
    /// Logs into Sourced and, if successful, returns a token.
    public func linkDevice() async throws {
        guard let userToken = userToken else { throw "Not logged in." }
        var request = URLRequest(url: .sourcedRepo)
        request.httpMethod = "POST"
        request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        
        let (_, statusCode) = try await requestData(request: request, endpoint: "account/linkDevice?id=\(udid())")
        print("[SourcedRepoFetcher] \(statusCode)")
        switch statusCode {
        case 406:
            throw "You've reached the maximum amount of linked devices to your account. Please remove some at repo.sourceloc.net/account/devices. (406)"
        case 208, 200: break
        default:
            throw "Something went wrong while linking the device. (\(statusCode))"
        }
    }
    
    public func logout() {
        userToken = nil
        username = nil
        email = nil
        self.showLogin = true
    }
    
    public func getLatestVersion(shortName: String) async throws -> (String,String,String) {
        var request = URLRequest(url: .sourcedRepo)
        request.httpMethod = "GET"
        let (data, statusCode) = try await requestData(request: request, endpoint: "packages/\(shortName)/latest")
        guard statusCode == 200 else { throw "Couldn't get latest version. \(statusCode)" }
        let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String: Any]
        guard let version = json["version"] as? String else { throw "Couldn't parse version." }
        guard let build = json["build"] as? String else { throw "Couldn't parse build string." }
        guard let changelog = json["changelog"] as? String else { throw "Couldn't parse changelog string." }
        return (version,build,changelog)
    }
    
    private func getDownloadCodeForTheme(repoTheme: RepoTheme) async throws -> String {
        guard let userToken = userToken else { throw "Not logged in." }
        var request = URLRequest(url: .sourcedRepo)
        request.httpMethod = "GET"
        request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        let (data, statusCode) = try await requestData(request: request, endpoint: "themes/getDownloadCode?themeShortName=\(repoTheme.shortName)")
        guard statusCode == 200 else { throw "Couldn't get download code for the theme. (\(statusCode))" }
        
        return String(data: data, encoding: .utf8)!
    }
    
    private func getDownloadCodeForIPA() async throws -> String {
        guard let userToken = userToken else { throw "Not logged in." }
        var request = URLRequest(url: .sourcedRepo)
        request.httpMethod = "GET"
        request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        let (data, statusCode) = try await requestData(request: request, endpoint: "packages/getDownloadCode?packageShortName=picasso")
        guard statusCode == 200 else { throw "Couldn't get download code for the package. (\(statusCode))" }
        
        return String(data: data, encoding: .utf8)!
    }
    
    /// insanely broken, please do not use
    public func getUpdateURL() async throws/* -> URL*/ {
        guard let userToken = userToken else { throw "Not logged in." }
        let code = try await getDownloadCodeForIPA()
        
        let url = URL.sourcedRepo.deletingLastPathComponent().appendingPathComponent("picasso.ipa").absoluteString + "?code=\(code)"
        var request = URLRequest(url: .init(string: "https://" + url)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw "Couldn't fetch theme using the obtained code. \((response as? HTTPURLResponse)?.statusCode ?? -1)" }
    }
    
    public func requestCheckoutSession(packageShortName: String, paymentMethod: String = "card") async throws -> URL {
        
        guard let userToken = userToken else { throw "Not logged in." }
        var request = URLRequest(url: .sourcedRepo)
        request.httpMethod = "POST"
        request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        let (data, statusCode) = try await requestData(request: request, endpoint: "packages/createCheckoutSession?packageShortName=\(packageShortName)&paymentMethod=\(paymentMethod)")
        guard statusCode == 200 else { throw "Couldn't request a checkout session. (\(statusCode))" }
        let urlStr = String(data: data, encoding: .utf8)!
        guard let url = URL(string: urlStr) else { throw "Server returned an unknown error. (\(urlStr))" }
        return url
    }
    
    
    
    /// Sends a request to server, uses mirrors if necessary
    public func requestData(request: URLRequest, endpoint: String) async throws -> (Data, Int) {
        let customBackendURL = UserDefaults.standard.string(forKey: "customBackendURL") // debugging
        let hosts = customBackendURL != nil ? [customBackendURL!] : ["https://server1.sourceloc.net/v1/","https://drm-09c0a19f69b2.deno.dev/v1/"]
        var _data: Data? = nil
        var _statusCode: Int? = nil
        for host in hosts {
            do {
                var request = request
                request.url = URL(string: host + endpoint)!
                request.timeoutInterval = 5
                let (responseData, response) = try await URLSession.shared.data(for: request)
                currentServerHost = host.replacingOccurrences(of: "v1/", with: "")
                _data = responseData
                _statusCode = (response as? HTTPURLResponse)?.statusCode
                break
            }
        }
        guard let _data, let _statusCode else { throw "Connection error. Could not any mirrors for Sourced Repo server."}
        return (_data, _statusCode)
    }
    
    public func sendApplyLogs(themes: [[String]]) async throws {
        guard let userToken = userToken else { throw "Not logged in." }
        var request = URLRequest(url: .sourcedRepo)
        request.httpMethod = "POST"
        request.addValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        
        let json: [String: Any] = ["themes": themes]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        let (_, statusCode) = try await requestData(request: request, endpoint: "themes/analytics")
        print("[SourcedRepoFetcher] \(statusCode)")
        switch statusCode {
        case 208, 200: break
        default: break
        }
    }
    
    private func udid() -> String {
//        UDIDInator.getUDID()
        return ""
    }
}

extension URL {
    static var sourcedRepo: URL {
        #if DEBUG
        if let customURL = UserDefaults.standard.string(forKey: "customBackendURL") {
            if customURL == "" { return .init(string: "server1.sourceloc.net/v1/")! }
            return .init(string: customURL)!
        } else {
            return .init(string: "server1.sourceloc.net/v1/")!
        }
        #else
        return .init(string: "server1.sourceloc.net/v1/")!
        #endif
    }
}
