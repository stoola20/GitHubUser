////
//  DetailViewModel.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/15.
//

import Foundation
import RxCocoa
import RxRelay
import RxSwift

/// Inputs for the `DetailViewModel`.
protocol DetailViewModelInputs {
    /// The username associated with the user detail to be fetched.
    var userName: String? { get set }
    /// Triggers fetching the user detail.
    func getUserDetail()
}

/// Outputs for the `DetailViewModel`.
protocol DetailViewModelOutputs {
    /// Emits the user detail fetched from the API.
    var detailUserRelay: PublishRelay<DetailUser> { get }
    var errorRelay: PublishRelay<String> { get }
}

/// Combined inputs and outputs protocol for the `DetailViewModel`.
protocol DetailViewModelType {
    var inputs: DetailViewModelInputs { get }
    var outputs: DetailViewModelOutputs { get }
}

class DetailViewModel: DetailViewModelInputs, DetailViewModelOutputs, DetailViewModelType {
    // MARK: Type

    var inputs: DetailViewModelInputs { self }
    var outputs: DetailViewModelOutputs { self }

    private let disposeBag = DisposeBag()
    private let interactor: UserInteractor

    // MARK: Inputs

    var userName: String?

    private let getUserDetailRelay: PublishRelay<Void> = .init()
    func getUserDetail() {
        getUserDetailRelay.accept(())
    }

    // MARK: Outputs

    let detailUserRelay: PublishRelay<DetailUser> = .init()
    var errorRelay: PublishRelay<String> = .init()

    init(interactor: UserInteractor) {
        self.interactor = interactor

        // Define a trigger for fetching user detail and handle any errors that occur during the API request
        let detailTrigger = getUserDetailRelay
            .asObservable()
            .withUnretained(self)
            .flatMap { owner, _ -> Observable<DetailUser> in
                // Ensure that a valid username is available before proceeding with fetching user detail
                guard let userName = owner.userName else { return Observable.empty() }

                return owner.interactor.getUserDetail(userName: userName)
                    .catch { error in
                        // Map server errors to their descriptions and notify the view model's error relay
                        let serverError = (error as? ServerError) ?? .unknownError
                        owner.errorRelay.accept(serverError.errorDescription)
                        return Observable.empty()
                    }
            }
            .share()

        // Bind the emitted user detail to the detailUserRelay for consumption by the view
        detailTrigger
            .bind(to: detailUserRelay)
            .disposed(by: disposeBag)
    }
}
