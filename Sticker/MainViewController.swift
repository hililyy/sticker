//
//  MainViewController.swift
//  Sticker
//
//  Created by 강조은 on 2023/10/30.
//

import UIKit

final class MainViewController: UIViewController {
    
    let mainView = MainView()
    
    private let imageViewStrings = ["birthday", "cake", "cat", "cow", "dog", "pie", "rabbit"]
    
    private var selectedSticker: StickerView? {
        didSet(oldValue) {
            if let sticker = oldValue {
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
    
    private func initalize() {
        initView()
        initTarget()
        initDelegate()
        initGesture()
    }
    
    private func initView() {
        view.backgroundColor = .white
    }
    
    private func initTarget() {
        mainView.saveButton.addTarget(self,
                                      action: #selector(mergeImage),
                                      for: .touchUpInside)
    }
    
    private func initDelegate() {
        mainView.stickerListCollectionView.delegate = self
        mainView.stickerListCollectionView.dataSource = self
    }
    
    private func initGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(_:)))
        mainView.backgroundImageView.addGestureRecognizer(tapGesture)
    }
}

extension MainViewController {
    @objc private func mergeImage() {
        if mainView.backgroundImageView.subviews.count > 0 {
            selectedSticker = nil
            if let image = mergeImages(imageView: mainView.backgroundImageView) {
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        } else {
            print("스티커 사용 안댐")
        }
    }
    
    private func mergeImages(imageView: UIImageView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0.0)
        imageView.superview!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            print("오류댱")
        } else {
            print("저장됨")
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        for view in mainView.backgroundImageView.subviews {
            if !view.frame.contains(location) {
                selectedSticker = nil
            }
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
        stickerView.initImageWidth = 100
        stickerView.initImageHeight = 100
        stickerView.initFrame()
        stickerView.parentVC = self
        stickerView.delegate = self
        stickerView.deleteHandler = {
            self.selectedSticker?.removeFromSuperview()
        }
        selectedSticker = stickerView
        mainView.backgroundImageView.addSubview(stickerView)
    }
}

extension MainViewController: StickerDelegate {
    func selectSticker(stickerView: StickerView) {
        selectedSticker = stickerView
    }
}
