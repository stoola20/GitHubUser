////
//  UserInteractor.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/13.
//

import Alamofire
import Foundation
import RxSwift

protocol UserInteractorProtocol {
    func getUserList(since: Int, pageSize: Int) -> Observable<([GitHubUser], [String: Any]?)>
    func getNextUserPage(link: String) -> Observable<([GitHubUser], [String: Any]?)>
    func getUserDetail(userName: String) -> Observable<DetailUser>
}

/// Interactor responsible for fetching user data from the GitHub API.
final class UserInteractor: UserInteractorProtocol, RequestProtocol {
    /// Fetches a list of GitHub users.
    ///
    /// - Parameters:
    ///   - since: The user ID to start fetching users from.
    ///   - pageSize: The number of users to fetch per page. Default is 20.
    /// - Returns: An observable sequence of GitHub users.
    func getUserList(since: Int, pageSize: Int = 20) -> Observable<([GitHubUser], [String: Any]?)> {

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
    
    /// Fetches the next page of GitHub users based on the provided link.
    ///
    /// - Parameter link: The link to the next page of users.
    /// - Returns: An observable sequence containing a tuple of GitHub users and response headers.
    func getNextUserPage(link: String) -> Observable<([GitHubUser], [String: Any]?)> {
        let url = URL(string: link)
        
        // Make a network request to fetch the user list
        return request(
            url: url,
            method: .get,
            parameters: nil,
            header: HTTPHeaderManager.shared.getDefaultHeaders(),
            type: [GitHubUser].self
        )
    }
    
    /// Fetches detailed information for a specific GitHub user.
    ///
    /// - Parameter userName: The username of the GitHub user.
    /// - Returns: An observable sequence containing the detailed information of the user.
    func getUserDetail(userName: String) -> Observable<DetailUser> {
        // Construct API endpoint for fetching user detail info
        let api = GitHubAPI.getUserDetail(userName: userName)
        let url = URL(string: api.baseURL + api.path)
            
        // Make a network request to fetch the user detail
        return request(
            url: url,
            method: api.method,
            parameters: api.parameters,
            header: api.header,
            type: DetailUser.self
        )
    }
}
