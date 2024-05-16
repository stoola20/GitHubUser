////
//  ListUserViewModel.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/14.
//

import Foundation
import RxRelay
import RxSwift

/// Inputs for the `ListUserViewModel`.
protocol ListUserViewModelInputs {
    /// Called when the view controller is loaded.
    func viewDidLoad()
    /// Called when more users need to be loaded.
    func loadMore()
}

/// Outputs for the `ListUserViewModel`.
protocol ListUserViewModelOutputs {
    /// A relay for the list of GitHub users.
    var userListRelay: BehaviorRelay<[GitHubUser]> { get }
    var errorRelay: PublishRelay<String> { get }
}

/// Combined inputs and outputs for the `ListUserViewModel`.
protocol ListUserViewModelType {
    var inputs: ListUserViewModelInputs { get }
    var outputs: ListUserViewModelOutputs { get }
}

class ListViewModel: ListUserViewModelInputs, ListUserViewModelOutputs, ListUserViewModelType {
    // MARK: Type

    var inputs: ListUserViewModelInputs { self }
    var outputs: ListUserViewModelOutputs { self }

    let disposeBag = DisposeBag()
    let interactor: UserInteractorProtocol

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
    var errorRelay: PublishRelay<String> = .init()

    init(interactor: UserInteractorProtocol) {
        self.interactor = interactor

        // Define a trigger to fetch user list data when the getUserListRelay is triggered.
        let initialTrigger = getUserListRelay
            .asObservable()
            .withUnretained(self)
            .flatMap { owner, since -> Observable<[GitHubUser]> in
                // Call the getUserList method to fetch user list data.
                owner.interactor.getUserList(since: since, pageSize: 20)
                    .do { _, headers in
                        // parse nextLink from headers and store it to nextLinkRelay
                        if let headers,
                           let link = headers["Link"] as? String,
                           let nextLink = link.getNextLinkFromLinkHeader() {
                            owner.nextLinkRelay.accept(nextLink)
                        }
                    }
                    .catch { error in
                        // Map server errors to their descriptions and notify the view model's error relay
                        let serverError = (error as? ServerError) ?? .unknownError
                        owner.errorRelay.accept(serverError.errorDescription)
                        return Observable.empty()
                    }
                    .map { userList, _ in
                        userList
                    }
            }

        // Subscribe to the trigger to update the userListRelay with the fetched user list data.
        initialTrigger
            .bind(to: userListRelay)
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
                    .catch { error in
                        // Map server errors to their descriptions and notify the view model's error relay
                        let serverError = (error as? ServerError) ?? .unknownError
                        owner.errorRelay.accept(serverError.errorDescription)
                        return Observable.empty()
                    }
                    .map { userList, _ in
                        userList
                    }
            }

        loadMore
            .withUnretained(self)
            .map { owner, newUserList in
                let prevUserList = owner.userListRelay.value
                return prevUserList + newUserList
            }
            .bind(to: userListRelay)
            .disposed(by: disposeBag)
    }
}
