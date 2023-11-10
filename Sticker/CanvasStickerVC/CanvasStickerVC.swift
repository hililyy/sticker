//
//  CanvasStickerVC.swift
//  Sticker
//
//  Created by 강조은 on 2023/10/30.
//

import UIKit

final class CanvasStickerVC: StickerBaseVC {
    
    let mainView = CanvasStickerView()
    
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
    
    var info = StickerTextModel()
    
    private func resetSelectedStickerUI(selectedSticker: StickerView?) {
        for view in mainView.backgroundImageView.subviews {
            if let sticker = view as? StickerView {
                sticker.isHiddenBorderView(isSelected: view == selectedSticker)
                mainView.editButton.isHidden = selectedSticker?.type != .label
            } else {
                mainView.editButton.isHidden = true
            }
        }
    }
    
    private func addStickerView(contentView: UIView, type: StickerType, size: CGSize? = nil) {
        
        let stickerView = StickerView(contentsView: contentView)
        var newSize: CGSize = size ?? .zero
        
        if type == .image {
            newSize = getNewSize(size: contentView.frame.size)
        }
        
        stickerView.type = type
        stickerView.initImageWidth = newSize.width
        stickerView.initImageHeight = newSize.height
        
        stickerView.parentVC = self
        stickerView.delegate = self
        stickerView.stickerInfo = info
        
        mainView.backgroundImageView.addSubview(stickerView)
        
        if stickerView.type == .image {
            initAnimation(view: stickerView)
        }
        
        stickerView.initFrame()
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
    
    private func clearStickerInfo() {
        info.isEdit = false
        info.lastPosition = .zero
        info.lastRotationAngle = 0
        info.lastScale = 0
    }
}

// MARK: - Protocol Function
extension CanvasStickerVC: StickerDelegate {
    func tapLabelSticker(info: StickerTextModel) {
        self.info = info
        self.info.isEdit = true
    }
    
    func selectSticker(stickerView: StickerView) {
        selectedSticker = stickerView
        if stickerView.type == .image {
            clearStickerInfo()
        }
    }
}

// MARK: - Initalize
extension CanvasStickerVC {
    private func initalize() {
        initTarget()
        initDelegate()
        initGesture()
    }
    
    private func initTarget() {
        mainView.saveButton.addTarget(self,
                                      action: #selector(saveImage),
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
        
        mainView.editButton.addTarget(self,
                                      action: #selector(editTextField),
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
    
    @objc private func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        for view in mainView.backgroundImageView.subviews {
            if !view.frame.contains(location) {
                selectedSticker = nil
            }
        }
    }
}

// MARK: - Target Function
extension CanvasStickerVC {
    @objc private func saveImage() {
        if mainView.backgroundImageView.subviews.count <= 0 {
            toast(message: "붙은 스티커 없음")
            return
        }
        
        selectedSticker = nil
        
        guard let mergedImage = mainView.backgroundImageView.mergeImage() else { return }
        mergedImage.saveImageAsPhoto()
        toast(message: "저장됐슴")
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
            info.text = text
            clearStickerInfo()
            addStickerView(contentView: labelImage,
                           type: .label,
                           size: smallRect)
        }
        
        present(vc, animated: true)
    }
    
    @objc func editTextField() {
        let vc = TextFieldPopupVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        if !info.text.isEmpty {
            vc.textFieldPopupView.contentsTextView.text = info.text
        }
        
        vc.completeHandler = { [weak self] text in
            guard let self else { return }
            guard let selectedSticker else { return }
            selectedSticker.removeFromSuperview()
            let largeLabel = self.getLabelbyFont(text: text, fontSize: 500)
            
            let smallRect = CGSize(width: largeLabel.bounds.width * 0.1,
                                   height: largeLabel.bounds.height * 0.1)
            let labelImage = UIImageView(image: largeLabel.convertToImage())
            info.text = text
            addStickerView(contentView: labelImage,
                           type: .label,
                           size: smallRect)
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

// MARK: - CollectionView
extension CanvasStickerVC: UICollectionViewDataSource, UICollectionViewDelegate {
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
        addStickerView(contentView: img,
                       type: .image)
    }
}

// MARK: - Photo Album
extension CanvasStickerVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController( _ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let img = UIImageView(image: selectedImage)
            addStickerView(contentView: img,
                           type: .image)
        }
        
        dismiss(animated: true)
    }
}
