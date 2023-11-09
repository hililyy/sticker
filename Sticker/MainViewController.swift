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
        didSet {
            resetSelectedStickerUI(selectedSticker: selectedSticker)
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
//        if let sticker = selectedSticker {
//            sticker.superview?.bringSubviewToFront(sticker)
//        }
        
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
        mergedImage.saveImageAsPhoto()
        toast(message: "저장됐슴")
        
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
        vc.completeHandler = { [weak self] text in
            guard let self else { return }
            
            let largeLabel = self.getLabelbyFont(text: text, fontSize: 500)
            
            let smallRect = CGSize(width: largeLabel.bounds.width * 0.1,
                                   height: largeLabel.bounds.height * 0.1)
            let labelImage = UIImageView(image: largeLabel.convertToImage())
            
            addStickerView(contentView: labelImage, size: smallRect)
        }
        present(vc, animated: true)
    }
    
    private func getLabelbyFont(text: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Ownglyph_RDO_ballpen-Rg", size: fontSize)
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }
    
    @objc private func movefrontLayer() {
        if let sticker = selectedSticker {
            if let index = sticker.superview?.subviews.firstIndex(of: sticker) {
                sticker.superview?.insertSubview(sticker, at: index + 1)
            }
        }
    }
    
    @objc private func movebackLayer() {
        if let sticker = selectedSticker {
            if let index = sticker.superview?.subviews.firstIndex(of: sticker) {
                sticker.superview?.insertSubview(sticker, at: index - 1)
            }
        }
    }
    
    @objc private func moveTopLayer() {
        if let sticker = selectedSticker {
            sticker.superview?.bringSubviewToFront(sticker)
        }
    }
    
    @objc private func moveBottomLayer() {
        if let sticker = selectedSticker {
            sticker.superview?.sendSubviewToBack(sticker)
        }
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
        
        mainView.frontLayerButton.addTarget(self,
                                          action: #selector(movefrontLayer),
                                          for: .touchUpInside)
        
        mainView.backLayerButton.addTarget(self,
                                          action: #selector(movebackLayer),
                                          for: .touchUpInside)
        
        mainView.topLayerButton.addTarget(self,
                                          action: #selector(moveTopLayer),
                                          for: .touchUpInside)
        
        mainView.bottomLayerButton.addTarget(self,
                                          action: #selector(moveBottomLayer),
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
    
    private func addStickerView(contentView: UIView, size: CGSize? = nil) {
        let stickerView = StickerView(contentsView: contentView)
        var newSize = getNewSize(size: contentView.frame.size)
        
        if let size {
            newSize = size
        }
        
        stickerView.initImageWidth = newSize.width
        stickerView.initImageHeight = newSize.height
        
        stickerView.parentVC = self
        stickerView.delegate = self
        
        stickerView.initFrame()
        mainView.backgroundImageView.addSubview(stickerView)
        initAnimation(view: stickerView)
        
        selectedSticker = stickerView
    }
    
    private func getNewSize(size: CGSize) -> CGSize {
        var newSize: CGSize = .zero
        let minimumSize: CGFloat = 100
        
        if size.width > size.height {
            newSize.width = size.width * minimumSize / size.height
            newSize.height = minimumSize
        } else {
            newSize.width = minimumSize
            newSize.height = size.height * minimumSize / size.width
        }
        
        return newSize
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
