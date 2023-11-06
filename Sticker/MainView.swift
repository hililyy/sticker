//
//  MainView.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/06.
//

import UIKit

final class MainView: UIView {
    
    let saveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
    private let contentView = UIView()
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "image"))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private var bottomView = UIView()
    lazy var stickerListCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        view.isScrollEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
        view.contentInset = .zero
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.register(StickerListCVCell.self, forCellWithReuseIdentifier: StickerListCVCell.identifier)
        return view
    }()
    
    private let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8.0
        layout.itemSize = CGSize(width: 80, height: 80)
        return layout
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubView() {
        addSubview(saveButton)
        addSubview(contentView)
        contentView.addSubview(backgroundImageView)
        addSubview(bottomView)
        bottomView.addSubview(stickerListCollectionView)
    }
    
    private func initConstraints() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        stickerListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant:
                                                0),
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: stickerListCollectionView.topAnchor),
            
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            bottomView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 100),
            
            stickerListCollectionView.topAnchor.constraint(equalTo: bottomView.topAnchor),
            stickerListCollectionView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            stickerListCollectionView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            stickerListCollectionView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor)
        ])
    }
}
