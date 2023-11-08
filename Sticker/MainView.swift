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
    
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("사진 선택", for: .normal)
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let inputTextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("텍스트", for: .normal)
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = .purple
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let frontLayerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("앞", for: .normal)
        button.backgroundColor = .yellow
        button.layer.cornerRadius = 5
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
    let backLayerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("뒤", for: .normal)
        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let topLayerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("젤앞", for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let bottomLayerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("젤뒤", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [saveButton,
                                                       selectPhotoButton,
                                                       inputTextButton,
                                                       frontLayerButton,
                                                       backLayerButton,
                                                       topLayerButton,
                                                       bottomLayerButton])
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
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
        
        initUI()
        initSubView()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        backgroundColor = .white
    }
    
    private func initSubView() {
        addSubview(buttonStackView)
        addSubview(contentView)
        contentView.addSubview(backgroundImageView)
        addSubview(bottomView)
        bottomView.addSubview(stickerListCollectionView)
    }
    
    private func initConstraints() {
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        selectPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        stickerListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: -20),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40),
            
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
