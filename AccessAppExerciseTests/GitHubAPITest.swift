////
//  GitHubAPITest.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/15.
//

@testable import AccessAppExercise
import XCTest

final class GitHubAPITest: XCTestCase {
    func testPath() {
        XCTAssertEqual(GitHubAPI.getUserList(since: 0, pageSize: 20).path, "/users")
        XCTAssertEqual(GitHubAPI.getUserDetail(userName: "jesse").path, "/users/jesse")
    }
    
    func testParameters() {
        XCTAssertEqual(
            GitHubAPI.getUserList(since: 0, pageSize: 20).parameters,
            ["since": "0",
             "per_page": "20"]
        )

        XCTAssertEqual(GitHubAPI.getUserDetail(userName: "jesse").parameters, nil)
    }
}
