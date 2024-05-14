////
//  RequestHeader.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/13.
//

import Foundation

/// Protocol defining a custom HTTP header.
protocol CustomHeader {
    /// The key of the HTTP header.
    var key: String { get }
    /// The value of the HTTP header.
    var value: String { get }
}

/// Struct representing the 'Accept' header for GitHub API requests.
struct AcceptHeader: CustomHeader {
    var key: String { return "Accept" }
    var value: String { return "application/vnd.github+json" }
}

/// Struct representing the 'X-GitHub-Api-Version' header for GitHub API requests.
struct APIVersionHeader: CustomHeader {
    var key: String { return "X-GitHub-Api-Version" }
    var value: String { return "2022-11-28" }
}

/// Struct representing the 'Authorization' header for GitHub API requests.
struct AuthorizationHeader: CustomHeader {
    var key: String { return "Authorization" }
    var value: String { return "Bearer \(PersonalAccessToken.token)" }
}
