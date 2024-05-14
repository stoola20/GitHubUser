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
    /// A relay to trigger fetching the user list.
    var getUserListRelay: PublishRelay<Int> { get }
    /// Called when the view controller is loaded.
    func viewDidLoad()
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

class ListUserViewModel: ListUserViewModelInputs, ListUserViewModelOutputs, ListUserViewModelType {
    // MARK: Type

    var inputs: ListUserViewModelInputs { self }
    var outputs: ListUserViewModelOutputs { self }

    let disposeBag = DisposeBag()
    let interactor: UserInteractor

    // MARK: Inputs

    let getUserListRelay: PublishRelay<Int> = .init()

    func viewDidLoad() {
        // initial userID start after 0
        getUserListRelay.accept(0)
    }

    // MARK: Outputs

    var userListRelay: BehaviorRelay<[GitHubUser]> = .init(value: [])

    init(interactor: UserInteractor) {
        self.interactor = interactor

        // Define a trigger to fetch user list data when the getUserListRelay is triggered.
        let trigger = getUserListRelay
            .asObservable()
            .withUnretained(self)
            .flatMap { owner, since -> Observable<[GitHubUser]> in
                // Call the getUserList method to fetch user list data.
                owner.interactor.getUserList(since: since)
            }

        // Subscribe to the trigger to update the userListRelay with the fetched user list data.
        trigger
            .withUnretained(self)
            .subscribe { owner, userList in
                // Update the userListRelay with the fetched user list data.
                owner.userListRelay.accept(userList)
            } onError: { error in
                // Error handle.
                print(error)
            }
            .disposed(by: disposeBag)
    }
}
