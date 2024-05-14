////
//  UserInteractor.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/13.
//

import Foundation
import RxSwift

/// Interactor responsible for fetching user data from the GitHub API.
final class UserInteractor: RequestProtocol {
    /// Fetches a list of GitHub users.
    ///
    /// - Parameters:
    ///   - since: The user ID to start fetching users from.
    ///   - pageSize: The number of users to fetch per page. Default is 20.
    /// - Returns: An observable sequence of GitHub users.
    func getUserList(since: Int, pageSize: Int = 20) -> Observable<[GitHubUser]> {

        // Construct API endpoint for fetching user list
        let api = GitHubAPI.getUserList(since: since, pageSize: pageSize)
        let url = URL(string: api.baseURL + api.path)
        
        // Make a network request to fetch the user list
        return request(
            url: url,
            method: api.method,
            parameters: api.parameters,
            header: api.header,
            type: [GitHubUser].self
        )
    }
}
