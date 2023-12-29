//
//  CanvasStickerView.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/06.
//

import UIKit

final class CanvasStickerView: UIView {
    private var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
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
    
    let saveButton = SimpleButton(name: "저장")
    let selectPhotoButton = SimpleButton(name: "사진선택")
    let inputTextButton = SimpleButton(name: "텍스트")
    let frontLayerButton = SimpleButton(name: "앞")
    let backLayerButton = SimpleButton(name: "뒤")
    let topLayerButton = SimpleButton(name: "젤앞")
    let bottomLayerButton = SimpleButton(name: "젤뒤")
    let editButton = SimpleButton(name: "편집")
    
    private let contentView = UIView()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let phoneImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "phone"))
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    
    let cameraImageView = UIImageView(image: UIImage(named: "camera"))
    
    var stickerBorderView = StickerBorderView()
    
    private var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var stickerListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8.0
        layout.itemSize = CGSize(width: 80, height: 80)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        collectionView.register(StickerListCVCell.self, forCellWithReuseIdentifier: StickerListCVCell.identifier)
        return collectionView
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
        
        editButton.isHidden = true
    }
    
    private func initSubView() {
        addSubview(topView)
        topView.addSubview(buttonStackView)
        
        addSubview(contentView)
        contentView.addSubview(backgroundView)
        
        backgroundView.addSubview(phoneImageView)
        phoneImageView.addSubview(cameraImageView)
        backgroundView.addSubview(stickerBorderView)
        backgroundView.addSubview(editButton)
        
        addSubview(bottomView)
        bottomView.addSubview(stickerListCollectionView)
    }
    
    private func initConstraints() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        phoneImageView.translatesAutoresizingMaskIntoConstraints = false
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        stickerListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: topAnchor),
            topView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topView.bottomAnchor.constraint(equalTo: contentView.topAnchor),
            
            buttonStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            buttonStackView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -10),
            buttonStackView.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40),
            
            editButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20),
            editButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            editButton.widthAnchor.constraint(equalToConstant: 60),
            editButton.heightAnchor.constraint(equalToConstant: 40),
            
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: stickerListCollectionView.topAnchor),
            
            backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            phoneImageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            phoneImageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            phoneImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 30),
            phoneImageView.widthAnchor.constraint(equalTo: phoneImageView.heightAnchor, multiplier: 528.0 / 1000),
            phoneImageView.heightAnchor.constraint(equalToConstant: 1000),
            
            cameraImageView.topAnchor.constraint(equalTo: phoneImageView.topAnchor, constant: 18),
            cameraImageView.leadingAnchor.constraint(equalTo: phoneImageView.leadingAnchor, constant: 22),
            cameraImageView.widthAnchor.constraint(equalTo: cameraImageView.heightAnchor, multiplier: 241 / 250),
            cameraImageView.heightAnchor.constraint(equalTo: phoneImageView.heightAnchor, multiplier: 1.1 / 4),
            
            bottomView.topAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 100),
            
            stickerListCollectionView.topAnchor.constraint(equalTo: bottomView.topAnchor),
            stickerListCollectionView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            stickerListCollectionView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            stickerListCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
