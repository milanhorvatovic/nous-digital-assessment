//
//  ListCell.swift
//  Nous Digital Assessment
//
//  Created by worker on 15/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import UIKit

import Strongify

import RxSwift
import RxCocoa

import Kingfisher
import RxKingfisher

final class ListCell: UITableViewCell {
    
    typealias ModelType = Model.Service.Item
    
    private lazy var previewImageView: UIImageView = self.createImageView()
    private lazy var titleLabel: UILabel = self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = self.createDescriptionLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(self.previewImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.descriptionLabel)
        
        self.previewImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.previewImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.previewImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.previewImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        self.titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        self.titleLabel.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 10).isActive = true
        
        self.descriptionLabel.leftAnchor.constraint(equalTo: self.titleLabel.leftAnchor).isActive = true
        self.descriptionLabel.rightAnchor.constraint(equalTo: self.titleLabel.rightAnchor).isActive = true
        self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 5).isActive = true
        self.descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: ModelType) {
        self.titleLabel.text = model.title
        self.descriptionLabel.text = model.description
        self.previewImageView.kf.setImage(with: model.imageURL,
                                          completionHandler: strongify(weak: self) { (self, result) in
                                            self.invalidateIntrinsicContentSize()
                                            self.layoutIfNeeded()
        })
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
}

extension ListCell {
    
    private func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
}
