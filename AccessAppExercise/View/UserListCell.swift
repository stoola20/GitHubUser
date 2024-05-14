////
//  UserListCell.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/14.
//

import UIKit

class UserListCell: UITableViewCell {
    /// The image view displaying the user's avatar.
    @IBOutlet weak var avatarImageView: UIImageView!
    /// The label displaying the username.
    @IBOutlet weak var loginLabel: UILabel!
    /// The view indicating if the user is a site administrator.
    @IBOutlet weak var badgeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        // Configure cell UI when the cell's bounds change.
        configureUI()
    }
    
    func layoutCell(with user: GitHubUser) {
        loginLabel.text = user.login
        badgeView.isHidden = !user.siteAdmin
        avatarImageView.loadImage(user.avatarUrl)
    }
    
    private func configureUI() {
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }
}
