//
//  StickerListCVCell.swift
//  Sticker
//
//  Created by 강조은 on 2023/10/30.
//

import UIKit

final class StickerListCVCell: UICollectionViewCell {
    
    static let identifier = "StickerListCVCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
        initConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        contentView.addSubview(imageView)
    }
    
    private func initConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}
