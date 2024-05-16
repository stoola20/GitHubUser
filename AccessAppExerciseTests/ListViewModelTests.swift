////
//  ListViewModelTests.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/16.
//

import XCTest
@testable import AccessAppExercise
import RxSwift

final class ListViewModelTests: XCTestCase {
    var sut: ListViewModel!
    var interactor: MockUserInteractor!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        interactor = MockUserInteractor()
        sut = ListViewModel(interactor: interactor)
        disposeBag = DisposeBag()
        super.setUp()
    }
    
    override func tearDown() {
        interactor = nil
        sut = nil
        disposeBag = nil
        super.tearDown()
    }

    func testGetUserList_Success() {
        // Given
        let userList: [GitHubUser] = [
            GitHubUser(
                login: "uggedal",
                avatarUrl: "https://avatars.githubusercontent.com/u/71?v=4",
                siteAdmin: false
            ),
            GitHubUser(
                login: "bruce",
                avatarUrl: "https://avatars.githubusercontent.com/u/72?v=4",
                siteAdmin: true
            )
        ]
        
        let headers = [
            "Link": "<https://api.github.com/users?since=85&per_page=15>; rel=\"next\", <https://api.github.com/users{?since}>; rel=\"first\""
        ]

        interactor.stubbebUserListResult = .just((userList, headers))
        
        // When
        sut.viewDidLoad()
        
        // Then
        sut.outputs.userListRelay
            .subscribe { userList in
                XCTAssertEqual(userList[0].login, "uggedal")
                XCTAssertEqual(userList[1].siteAdmin, true)
            }
            .disposed(by: disposeBag)
    }
    
    func testGetUserList_Error() {
        // Given
        let errorMessage = "An unknown error occurred."
        interactor.stubbebUserListResult = .error(ServerError.unknownError)
        
        // When
        sut.viewDidLoad()
        
        // Then
        sut.outputs.errorRelay
            .subscribe { message in
                XCTAssertEqual(message, errorMessage)
            }
            .disposed(by: disposeBag)
    }
    
    func testGetUserListHeader_Success() {
        // Given
        let userList: [GitHubUser] = [
            GitHubUser(
                login: "uggedal",
                avatarUrl: "https://avatars.githubusercontent.com/u/71?v=4",
                siteAdmin: false
            )
        ]
        
        let headers = [
            "Link": "<https://api.github.com/users?since=85&per_page=15>; rel=\"next\", <https://api.github.com/users{?since}>; rel=\"first\""
        ]

        interactor.stubbebUserListResult = .just((userList, headers))
        
        // When
        sut.viewDidLoad()
        
        // Then
        sut.nextLinkRelay
            .subscribe { nextLink in
                XCTAssertEqual(nextLink, "https://api.github.com/users?since=85&per_page=15")
            }
            .disposed(by: disposeBag)
    }
    
    func testGetUserListHeader_InvalidHeader() {
        // Given
        let userList: [GitHubUser] = [
            GitHubUser(
                login: "uggedal",
                avatarUrl: "https://avatars.githubusercontent.com/u/71?v=4",
                siteAdmin: false
            )
        ]

        interactor.stubbebUserListResult = .just((userList, nil))
        
        // When
        sut.viewDidLoad()
        
        // Then
        sut.nextLinkRelay
            .subscribe(onNext: { nextLink in
                XCTAssertNil(nextLink)
            })
            .disposed(by: disposeBag)
       
    }

    func testLoadMore_Success() {
        // Given
        let prevUserList: [GitHubUser] = [
            GitHubUser(
                login: "uggedal",
                avatarUrl: "https://avatars.githubusercontent.com/u/71?v=4",
                siteAdmin: false
            )
        ]
        
        sut.outputs.userListRelay.accept(prevUserList)
        
        let newUserList: [GitHubUser] = [
            GitHubUser(
                login: "bruce",
                avatarUrl: "https://avatars.githubusercontent.com/u/72?v=4",
                siteAdmin: true
            )
        ]
        
        let newHeaders = [
            "Link": "<https://api.github.com/users?since=85&per_page=15>; rel=\"next\", <https://api.github.com/users{?since}>; rel=\"first\""
        ]

        interactor.stubbebUserListResult = .just((newUserList, newHeaders))
        
        // When
        sut.loadMore()
        
        // Then
        sut.outputs.userListRelay
            .subscribe { userList in
                XCTAssertEqual(userList[0].login, "uggedal")
                XCTAssertEqual(userList[1].siteAdmin, true)
            }
            .disposed(by: disposeBag)
    }

    func testLoadMore_Error() {
        // Given
        let errorMessage = "Failed to parse the response data."
        interactor.stubbebUserListResult = .error(ServerError.parsingFailure)
        
        // When
        sut.loadMore()
        
        // Then
        sut.outputs.errorRelay
            .subscribe { message in
                XCTAssertEqual(message, errorMessage)
            }
            .disposed(by: disposeBag)
    }

    func testLoadMoreHeader_Success() {
        // Given
        let userList: [GitHubUser] = [
            GitHubUser(
                login: "uggedal",
                avatarUrl: "https://avatars.githubusercontent.com/u/71?v=4",
                siteAdmin: false
            )
        ]
        
        let headers = [
            "Link": "<https://api.github.com/users?since=85&per_page=15>; rel=\"next\", <https://api.github.com/users{?since}>; rel=\"first\""
        ]

        interactor.stubbebUserListResult = .just((userList, headers))
        
        // When
        sut.loadMore()
        
        // Then
        sut.nextLinkRelay
            .subscribe { nextLink in
                XCTAssertEqual(nextLink, "https://api.github.com/users?since=85&per_page=15")
            }
            .disposed(by: disposeBag)
    }

    func testLoadMoreHeader_InvalidHeader() {
        // Given
        let userList: [GitHubUser] = [
            GitHubUser(
                login: "uggedal",
                avatarUrl: "https://avatars.githubusercontent.com/u/71?v=4",
                siteAdmin: false
            )
        ]

        interactor.stubbebUserListResult = .just((userList, nil))
        
        // When
        sut.viewDidLoad()
        
        // Then
        sut.nextLinkRelay
            .subscribe(onNext: { nextLink in
                XCTAssertNil(nextLink)
            })
            .disposed(by: disposeBag)
       
    }
}
