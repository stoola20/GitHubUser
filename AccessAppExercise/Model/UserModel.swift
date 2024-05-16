////
//  UserModel.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/13.
//

import Foundation
import RxDataSources

/// Structure representing a section in a user list, containing a header and a list of items.
/// This custom structure can be pass to RxDataSources as section type.
struct UserListSection {
    /// The header title of the section.
    var header: String
    /// The items contained within the section.
    var items: [Item]
}

extension UserListSection: SectionModelType {
    typealias Item = GitHubUser

    init(original: UserListSection, items: [GitHubUser]) {
        self = original
        self.items = items
    }
}

/// Struct representing a GitHub user.
struct GitHubUser: Decodable {
    /// The username of the GitHub user.
    let login: String
    /// The URL of the avatar image for the GitHub user.
    let avatarUrl: String
    /// A boolean value indicates whether showing STAFF badge or not.
    let siteAdmin: Bool
}

/// Struct representing detailed information about a GitHub user.
struct DetailUser: Decodable, Equatable {
    /// The URL of the avatar image for the GitHub user.
    let avatarUrl: String
    /// The full name of the GitHub user.
    let name: String?
    /// The biography of the GitHub user.
    let bio: String?
    /// The username of the GitHub user.
    let login: String
    /// A boolean value indicates whether showing STAFF badge or not.
    let siteAdmin: Bool
    /// The location of the GitHub user.
    let location: String?
    /// The URL of the personal website or blog of the GitHub user.
    let blog: String?
}
