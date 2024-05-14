////
//  BadgeView.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/14.
//

import UIKit

/// Custom UIView subclass representing a badge view with a rounded rectangular shape and a text label.
class BadgeView: UIView {
    private let padding: CGFloat = 8
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "STAFF"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Set the corner radius to make the badge view appear as a rounded rectangle.
        layer.cornerRadius = bounds.height / 2
    }

    private func setUpUI() {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
        
        backgroundColor = .systemIndigo
    }
}
