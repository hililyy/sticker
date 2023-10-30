//
//  ViewController.swift
//  Sticker
//
//  Created by 강조은 on 2023/10/30.
//

import UIKit

class ViewController: UIViewController {
    
    let imageViewStrings = ["birthday", "cake", "cat", "cow", "dog", "pie", "rabbit"]
    
    let saveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "image"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var stickerListCollectionView: UICollectionView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        initalize()
        initSubView()
        initConstraints()
        backgroundImageView.isUserInteractionEnabled = true
        saveButton.addTarget(self, action: #selector(mergeImage), for: .touchUpInside)
    }
    
    func initalize() {
        stickerListCollectionView.delegate = self
        stickerListCollectionView.dataSource = self
    }
    
    func initSubView() {
        view.addSubview(saveButton)
        view.addSubview(backgroundImageView)
        view.addSubview(stickerListCollectionView)
    }
    
    func initConstraints() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        stickerListCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            saveButton.bottomAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: -10),
            saveButton.heightAnchor.constraint(equalToConstant: 30),
            
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: stickerListCollectionView.topAnchor),
            
            stickerListCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stickerListCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stickerListCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stickerListCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}

extension ViewController {
    @objc func mergeImage() {
        print(backgroundImageView.subviews.count)
        if backgroundImageView.subviews.count > 0 {
            if let image = mergeImages(imageView: backgroundImageView) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                print("Image not found !!")
            }
        } else {
            print("스티커 사용 안댐")
        }
    }
    
    func mergeImages(imageView: UIImageView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0.0)
        imageView.superview!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            print("오류댱")
        } else {
            print("저장됨")
        }
    }
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageViewStrings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerListCVCell.identifier, for: indexPath) as! StickerListCVCell
        cell.imageView.image = UIImage(named: imageViewStrings[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let img = UIImageView(image: UIImage(named: imageViewStrings[indexPath.row]))
        let stickerView = StickerView(contentsView: img, frame: CGRect(x: backgroundImageView.bounds.size.width / 2, y: backgroundImageView.bounds.size.height / 2, width: 50, height: 50))
        stickerView.parentVC = self
        backgroundImageView.addSubview(stickerView)
    }
}
