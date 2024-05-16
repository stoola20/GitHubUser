////
//  DetailViewModelTest.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/15.
//

@testable import AccessAppExercise
import RxSwift
import XCTest

final class DetailViewModelTest: XCTestCase {
    var sut: DetailViewModel!
    var disposeBag: DisposeBag!
    var interactor: MockUserInteractor!

    override func setUp() {
        super.setUp()
        interactor = MockUserInteractor()
        sut = DetailViewModel(interactor: interactor)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        interactor = nil
        sut = nil
        disposeBag = nil
        super.tearDown()
    }

    func testGetUserDetail_Success() {
        // Given
        let stubDetailUser = DetailUser(
            avatarUrl: "https://avatars.githubusercontent.com/u/2?v=4",
            name: "Chris Wanstrath",
            bio: "🍔",
            login: "defunkt",
            siteAdmin: false,
            location: nil,
            blog: nil
        )
        
        interactor.stubbedGetUserDetailResult = Observable.just(stubDetailUser)
        sut.userName = "defunkt"
        
        // When
        sut.getUserDetail()
        
        // Then
        sut.outputs.detailUserRelay
            .subscribe { detailUser in
                XCTAssertEqual(detailUser, stubDetailUser)
            }
            .disposed(by: disposeBag)
    }
    
    func testGetUserDetail_Error() {
        // Given
        let errorMessage = "Server Error"
        interactor.stubbedGetUserDetailResult = Observable.error(ServerError.requestFailure(errorMessage))
        sut.userName = "defunkt"
        
        // When
        sut.getUserDetail()
        
        // Then
        sut.outputs.errorRelay
            .subscribe { message in
                XCTAssertEqual(message, errorMessage)
            }
            .disposed(by: disposeBag)
    }
    
    func testGetUserDetail_NoUserName() {
        // Given
        let expectation = expectation(description: "No user name provided.")
        expectation.isInverted = true
        
        // When
        sut.getUserDetail()
        
        sut.outputs.detailUserRelay
            .subscribe { _ in
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1)
    }
}
