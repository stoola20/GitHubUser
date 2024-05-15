////
//  DetailViewController.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/15.
//

import RxSwift
import UIKit

/// A view controller responsible for displaying user details.
class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    private let disposeBag = DisposeBag()

    /// Initializes the view controller with a view model and a username.
    ///
    /// - Parameters:
    ///   - viewModel: The view model for managing user detail data.
    ///   - userName: The username associated with the user detail to be fetched.
    init(viewModel: DetailViewModel, userName: String) {
        self.viewModel = viewModel
        super.init(nibName: "DetailViewController", bundle: nil)
        self.viewModel.userName = userName
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel.inputs.getUserDetail()
    }

    /// Binds the view model outputs to UI elements.
    func bindViewModel() {
        viewModel.outputs
            .detailUserRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { _, detailUser in
                print(detailUser)
            }
            .disposed(by: disposeBag)
    }
}
