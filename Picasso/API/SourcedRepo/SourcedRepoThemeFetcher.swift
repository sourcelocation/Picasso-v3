//
//  SourcedRepoThemeFetcher.swift
//  Picasso
//
//  Created by sourcelocation on 30/11/2023.
//

import Foundation

extension SourcedRepoFetcher {
    
    public struct RepoTheme: Codable {
        var name: String
        var author: String
        var shortName: String
        var iconCount: Int
        var fileName: String
        
        var packName: String
    }
    
    public func previewIconURL(appID: String, inTheme theme: RepoTheme) -> URL? {
        guard let currentServerHost else { return nil }
        return .init(string: "\(currentServerHost)\(theme.shortName)/\(appID)-large.png")
    }
    
    public func getThemes() async throws -> [RepoTheme] {
        var request = URLRequest(url: .sourcedRepo)
        request.httpMethod = "GET"
        let (data, statusCode) = try await requestData(request: request, endpoint: "themes/all")
        guard statusCode == 200 else { throw "Couldn't get latest version. \(statusCode)" }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let themes = try decoder.decode([RepoTheme].self, from: data)
        return themes
    }
}
