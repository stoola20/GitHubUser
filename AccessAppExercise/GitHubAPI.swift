////
//  APIEndpoint.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/13.
//

import Foundation
import Alamofire

/// Enum representing different endpoints of the GitHub API.
enum GitHubAPI {
    /// Endpoint to fetch a list of GitHub users.
    ///
    ///  - `since`: A user ID. Only return users with an ID greater than this ID.
    ///  - `pageSize`: The number of results per page (max 100)
    case getUserList(since: Int, pageSize: Int)

    /// Endpoint to fetch detailed information about a specific GitHub user.
    ///
    /// - `userName`: The handle for the GitHub user account.
    case getUserDetail(userName: String)
}

extension GitHubAPI {
    /// The base URL of the GitHub API.
    var baseURL: String {
        return "https://api.github.com"
    }
    
    /// The path component of the URL for the API endpoint.
    var path: String {
        switch self {
        case .getUserList:
            return "/users"
        case .getUserDetail(let userName):
            return "/users/\(userName)"
        }
    }
    
    /// The HTTP method used for the API request.
    var method: Alamofire.HTTPMethod {
        return .get
    }
    
    /// The HTTP header fields for the API request.
    var header: [String: String] {
        var defaultHeaders = defaultHeaders()

        let authorizationHeader = AuthorizationHeader()
        defaultHeaders[authorizationHeader.key] = authorizationHeader.value

        return defaultHeaders
    }
    
    /// The parameters to be included in the API request.
    var parameters: [String: String]? {
        switch self {
        case .getUserList(let since, let pageSize):
            return ["since": String(since),
                    "per_page": String(pageSize)]
        case .getUserDetail:
            return nil
        }
    }
    
    /// Generates default HTTP headers for the API request.
    private func defaultHeaders() -> [String: String] {
        var defaultHeader = HTTPHeaders.default.dictionary
        
        let acceptHeader = AcceptHeader()
        let apiVersionHeader = APIVersionHeader()
        
        defaultHeader[acceptHeader.key] = acceptHeader.value
        defaultHeader[apiVersionHeader.key] = apiVersionHeader.value
        
        return defaultHeader
    }
}
