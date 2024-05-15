////
//  ListUserViewModel.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/14.
//

import Foundation
import RxRelay
import RxSwift

/// Inputs for the list user view model.
protocol ListUserViewModelInputs {
    /// Called when the view controller is loaded.
    func viewDidLoad()
    /// Called when more users need to be loaded.
    func loadMore()
}

/// Outputs for the list user view model.
protocol ListUserViewModelOutputs {
    /// A relay for the list of GitHub users.
    var userListRelay: BehaviorRelay<[GitHubUser]> { get }
}

/// Combined inputs and outputs for the list user view model.
protocol ListUserViewModelType {
    var inputs: ListUserViewModelInputs { get }
    var outputs: ListUserViewModelOutputs { get }
}

class ListViewModel: ListUserViewModelInputs, ListUserViewModelOutputs, ListUserViewModelType {
    // MARK: Type

    var inputs: ListUserViewModelInputs { self }
    var outputs: ListUserViewModelOutputs { self }

    let disposeBag = DisposeBag()
    let interactor: UserInteractor

    // MARK: Inputs

    let nextLinkRelay: BehaviorRelay<String?> = .init(value: nil)

    let getUserListRelay: PublishRelay<Int> = .init()
    func viewDidLoad() {
        // initial userID start after 0
        getUserListRelay.accept(0)
    }
    
    let loadMoreRelay: PublishRelay<Void> = .init()
    func loadMore() {
        loadMoreRelay.accept(())
    }

    // MARK: Outputs

    var userListRelay: BehaviorRelay<[GitHubUser]> = .init(value: [])

    init(interactor: UserInteractor) {
        self.interactor = interactor

        // Define a trigger to fetch user list data when the getUserListRelay is triggered.
        let initialTrigger = getUserListRelay
            .asObservable()
            .withUnretained(self)
            .flatMap { owner, since -> Observable<[GitHubUser]> in
                // Call the getUserList method to fetch user list data.
                owner.interactor.getUserList(since: since)
                    .do { _, headers in
                        // parse nextLink from headers and store it to nextLinkRelay
                        if let headers,
                           let link = headers["Link"] as? String,
                           let nextLink = link.getNextLinkFromLinkHeader() {
                            owner.nextLinkRelay.accept(nextLink)
                        }
                    }
                    .map { userList, _ in
                        userList
                    }
            }

        // Subscribe to the trigger to update the userListRelay with the fetched user list data.
        initialTrigger
            .withUnretained(self)
            .subscribe { owner, userList in
                // Update the userListRelay with the fetched user list data.
                owner.userListRelay.accept(userList)
            } onError: { error in
                // Error handle.
                print(error)
            }
            .disposed(by: disposeBag)
        
        let loadMore = loadMoreRelay
            .asObservable()
            .withUnretained(self)
            .flatMap { owner, _ -> Observable<[GitHubUser]> in
                // Fetch the next page of user data using the link stored in nextLinkRelay
                owner.interactor.getNextUserPage(link: owner.nextLinkRelay.value ?? "")
                    .do { _, headers in
                        // parse nextLink from response headers and store it to nextLinkRelay
                        if let headers,
                           let link = headers["Link"] as? String,
                           let nextLink = link.getNextLinkFromLinkHeader() {
                            owner.nextLinkRelay.accept(nextLink)
                        }
                    }
                    .map { userList, _ in
                        userList
                    }
            }
        
        loadMore
            .withUnretained(self)
            .subscribe { owner, newUserList in
                // Append the new user list to the existing user list relay
                let prevUserList = owner.userListRelay.value
                owner.userListRelay.accept(prevUserList + newUserList)
            } onError: { error in
                // Error handle.
                print(error)
            }
            .disposed(by: disposeBag)
    }
}
