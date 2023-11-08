//
//  Extension.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/07.
//

import UIKit

extension UIImageView {
    func mergeImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        self.superview!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


extension UIImage {
    func saveImageAsPhoto(completion: @escaping () -> ()) {
        UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil)
        completion()
    }
}

extension UIView {
    func convertToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(self.bounds)
            layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
}
