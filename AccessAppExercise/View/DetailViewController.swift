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
    // MARK: UIView
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    @IBOutlet var personImageView: UIImageView!
    @IBOutlet var mappinImageView: UIImageView!
    @IBOutlet var linkImageView: UIImageView!
    @IBOutlet var blogLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var badgeView: BadgeView!
    
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
        configureUI()
        bindViewModel()
        viewModel.inputs.getUserDetail()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }

    /// Binds the view model outputs to UI elements.
    private func bindViewModel() {
        viewModel.outputs
            .detailUserRelay
            .asObservable()
            .withUnretained(self)
            .subscribe { owner, detailUser in
                owner.configureUser(detailUser)
            }
            .disposed(by: disposeBag)
    }
    
    /// Configuring UI elements
    private func configureUI() {
        avatarImageView.contentMode = .scaleAspectFill
        
        nameLabel.font = .systemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        
        bioLabel.font = .systemFont(ofSize: 17)
        bioLabel.textAlignment = .center
        bioLabel.numberOfLines = 0
        
        personImageView.image = UIImage(systemName: "person.fill")
        personImageView.tintColor = .black
        
        mappinImageView.image = UIImage(systemName: "mappin")
        mappinImageView.tintColor = .black
        
        linkImageView.image = UIImage(systemName: "link")
        linkImageView.tintColor = .black
        
        loginLabel.font = .systemFont(ofSize: 17)
        
        locationLabel.font = .systemFont(ofSize: 17)
        
        blogLabel.font = .systemFont(ofSize: 17)
        blogLabel.textColor = .tintColor
    }
    
    /// Configuring UI with detail user data
    private func configureUser(_ user: DetailUser) {
        avatarImageView.loadImage(user.avatarUrl, placeHolder: UIImage(systemName: "person.fill"))
        nameLabel.text = user.name
        bioLabel.text = user.bio
        loginLabel.text = user.login
        badgeView.isHidden = !user.siteAdmin
        locationLabel.text = user.location
        blogLabel.text = user.blog
    }
}
