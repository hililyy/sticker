//
//  StickerBaseVC.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/09.
//

import UIKit
import Photos

class StickerBaseVC: UIViewController {
    let imagePicker = UIImagePickerController()
    
}

// MARK: - Animation
extension StickerBaseVC {
    func initAnimation(view: UIView) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.8 // 시작 스케일
        animation.toValue = 1.0 // 최종 스케일
        animation.duration = 0.1
        
        view.layer.add(animation, forKey: "scaleAnimation")
    }
}

// MARK: - Toast
extension StickerBaseVC {
    func toast(message: String) {
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
extension StickerBaseVC {
    @objc func openPhotoAlbum() {
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
