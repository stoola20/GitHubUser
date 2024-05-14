////
//  ListUserViewController.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/13.
//  
//

import UIKit
import RxSwift

class ListUserViewController: UIViewController {
    private let viewModel: ListUserViewModel
    private let disposeBag = DisposeBag()

    /// Initializes the view controller with a view model.
    ///
    /// - Parameter viewModel: The view model for managing user data.
    init(viewModel: ListUserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()

        viewModel.inputs.viewDidLoad()
    }
    
    private func bindViewModel() {
        viewModel.outputs
            .userListRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { owner, userList in
                print(userList)
            }
            .disposed(by: disposeBag)
    }
}

