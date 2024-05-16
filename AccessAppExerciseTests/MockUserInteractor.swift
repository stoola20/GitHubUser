////
//  MockUserInteractor.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/15.
//

@testable import AccessAppExercise
import Foundation
import RxSwift

final class MockUserInteractor: UserInteractorProtocol {
    var stubbedGetUserDetailResult: Observable<DetailUser>!
    var stubbebUserListResult: Observable<([GitHubUser], [String: Any]?)>!

    func getUserList(since: Int, pageSize: Int) -> Observable<([GitHubUser], [String: Any]?)> {
        stubbebUserListResult
    }

    func getNextUserPage(link: String) -> Observable<([GitHubUser], [String: Any]?)> {
        stubbebUserListResult
    }

    func getUserDetail(userName: String) -> Observable<DetailUser> {
        stubbedGetUserDetailResult
    }
}
