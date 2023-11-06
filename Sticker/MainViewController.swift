//
//  MainViewController.swift
//  Sticker
//
//  Created by 강조은 on 2023/10/30.
//

import UIKit

final class MainViewController: UIViewController {
    
    let mainView = MainView()
    
    let imageViewStrings = ["birthday", "cake", "cat", "cow", "dog", "pie", "rabbit"]
    
    let stickerCount = 0
    var selectedSticker: StickerView? {
        didSet(newValue) {
            if let sticker = newValue {
                sticker.superview?.bringSubviewToFront(sticker)
            }
            for view in mainView.backgroundImageView.subviews {
                if let sticker = view as? StickerView {
                    sticker.setBorderView(isSelected: view == selectedSticker)
                }
            }
        }
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initalize()
    }
    
    func initalize() {
        initView()
        initTarget()
        initDelegate()
    }
    
    func initView() {
        view.backgroundColor = .white
    }
    
    func initTarget() {
        mainView.saveButton.addTarget(self, action: #selector(mergeImage), for: .touchUpInside)
    }
    
    func initDelegate() {
        mainView.stickerListCollectionView.delegate = self
        mainView.stickerListCollectionView.dataSource = self
    }
}

extension MainViewController {
    @objc func mergeImage() {
        print(mainView.backgroundImageView.subviews.count)
        if mainView.backgroundImageView.subviews.count > 0 {
            if let image = mergeImages(imageView: mainView.backgroundImageView) {
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


extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
        let stickerView = StickerView(
            contentsView: img,
            frame: CGRect(x: mainView.backgroundImageView.bounds.size.width / 2,
                          y: mainView.backgroundImageView.bounds.size.height / 2,
                          width: 100,
                          height: 100))
        stickerView.tag = stickerCount + 1
        stickerView.parentVC = self
        stickerView.delegate = self
        stickerView.tag = 1
        stickerView.deleteHandler = {
            print("지움")
            self.selectedSticker?.removeFromSuperview()
        }
        selectedSticker = stickerView
        mainView.backgroundImageView.addSubview(stickerView)
        
    }
}

extension MainViewController: StickerDelegate {
    func tapSticker(stickerView: StickerView) {
        selectedSticker = stickerView
    }
}
