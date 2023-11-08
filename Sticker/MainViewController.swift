//
//  MainViewController.swift
//  Sticker
//
//  Created by 강조은 on 2023/10/30.
//

import UIKit
import Photos

final class MainViewController: UIViewController {
    
    let mainView = MainView()
    let imagePicker = UIImagePickerController()
    
    private let imageViewStrings = ["birthday", "cake", "cat", "cow", "dog", "pie", "rabbit"]
    
    var selectedSticker: StickerView? {
        willSet {
            resetSelectedStickerUI(selectedSticker: newValue)
        }
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initalize()
    }
    
    private func resetSelectedStickerUI(selectedSticker: StickerView?) {
        if let sticker = selectedSticker {
            sticker.superview?.bringSubviewToFront(sticker)
        }
        
        for view in mainView.backgroundImageView.subviews {
            if let sticker = view as? StickerView {
                sticker.setBorderView(isSelected: view == selectedSticker)
            }
        }
    }
    
    @objc private func mergeImage() {
        if mainView.backgroundImageView.subviews.count <= 0 {
            toast(message: "붙은 스티커 없음")
            return
        }
        
        selectedSticker = nil
        
        guard let mergedImage = mainView.backgroundImageView.mergeImage() else { return }
        mergedImage.saveImageAsPhoto {
            self.toast(message: "저장됐슴")
        }
    }
    
    @objc private func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        for view in mainView.backgroundImageView.subviews {
            if !view.frame.contains(location) {
                selectedSticker = nil
            }
        }
    }
    
    @objc func openTextField() {
        let vc = TextFieldPopupVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.completeHandler = { text in
            let textView = UITextView()
            textView.text = text
            textView.backgroundColor = UIColor.clear
            textView.font = .systemFont(ofSize: 500)
            textView.sizeToFit()
            let labelImage = UIImageView(image: textView.convertToImage())
            self.addStickerView(contentView: labelImage)
            
        }
        present(vc, animated: true)
    }
}

// MARK: - Initalize
extension MainViewController {
    private func initalize() {
        initTarget()
        initDelegate()
        initGesture()
    }
    
    private func initTarget() {
        mainView.saveButton.addTarget(self,
                                      action: #selector(mergeImage),
                                      for: .touchUpInside)
        
        mainView.selectPhotoButton.addTarget(self,
                                             action: #selector(openPhotoAlbum),
                                             for: .touchUpInside)
        
        mainView.inputTextButton.addTarget(self,
                                           action: #selector(openTextField),
                                           for: .touchUpInside)
    }
    
    private func initDelegate() {
        mainView.stickerListCollectionView.delegate = self
        mainView.stickerListCollectionView.dataSource = self
        imagePicker.delegate = self
    }
    
    private func initGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(tap(_:)))
        mainView.backgroundImageView.addGestureRecognizer(tapGesture)
    }
    
    private func addStickerView(contentView: UIView) {
        let stickerView = StickerView(contentsView: contentView)
        
        if contentView.frame.width > contentView.frame.height {
            stickerView.initImageWidth = contentView.frame.width * 150 / contentView.frame.height
            stickerView.initImageHeight = 150
        } else {
            stickerView.initImageWidth = 100
            stickerView.initImageHeight = contentView.frame.height * 100 / contentView.frame.width
        }
        
        stickerView.parentVC = self
        stickerView.delegate = self
        selectedSticker = stickerView
        stickerView.initFrame()
        mainView.backgroundImageView.addSubview(stickerView)
        initAnimation(view: stickerView)
    }
}

// MARK: - CollectionView
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageViewStrings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerListCVCell.identifier, for: indexPath) as? StickerListCVCell else { return UICollectionViewCell() }
        cell.imageView.image = UIImage(named: imageViewStrings[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let img = UIImageView(image: UIImage(named: imageViewStrings[indexPath.row]))
        addStickerView(contentView: img)
    }
}

// MARK: - Protocol Function
extension MainViewController: StickerDelegate {
    func selectSticker(stickerView: StickerView) {
        selectedSticker = stickerView
    }
}

// MARK: - Util
extension MainViewController {
    private func initAnimation(view: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.8 // 시작 스케일
        animation.toValue = 1.0 // 최종 스케일
        animation.duration = 0.1
        
        view.layer.add(animation, forKey: "scaleAnimation")
    }
    
    private func toast(message: String) {
        let toastLabelWidth: CGFloat = 300
        let toastLabelHeight: CGFloat = 50
        let toastLabelX = (view.frame.size.width - toastLabelWidth) / 2
        let toastLabelY: CGFloat = view.frame.size.height - 100
        
        let toastLabel = UILabel(frame: CGRect(x: toastLabelX,
                                               y: toastLabelY,
                                               width: toastLabelWidth,
                                               height: toastLabelHeight))
        toastLabel.backgroundColor = .systemTeal
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 15
        toastLabel.clipsToBounds = true
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5,
                       delay: 1.5,
                       options: .curveEaseOut,
                       animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}

// MARK: - Photo Album
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController( _ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let img = UIImageView(image: selectedImage)
            addStickerView(contentView: img)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func openPhotoAlbum() {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.modalPresentationStyle = .currentContext
                self.present(self.imagePicker, animated: true)
            } else {
                self.toast(message: "앨범 접근 안댐")
            }
        }
    }
    
    private func albumAuth() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .denied:
            toast(message: "앨범 권한 거부댐")
            
        case .authorized:
            openPhotoAlbum()
            
        case .notDetermined, .restricted:
            PHPhotoLibrary.requestAuthorization { state in
                if state == .authorized {
                    self.openPhotoAlbum()
                } else {
                    self.dismiss(animated: true)
                }
            }
            
        default:
            break
        }
    }
}
