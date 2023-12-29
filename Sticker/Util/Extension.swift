//
//  Extension.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/07.
//

import UIKit

extension UIImage {
    func saveImageAsPhoto() {
        UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil)
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
            context.fill(bounds)
            layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
    
    func setMask(with image: UIImage?){
        guard let image else { return }
        let masklayer = CALayer()
        masklayer.frame.origin = .zero
        masklayer.frame.size = frame.size
        masklayer.contents = image.cgImage
        layer.mask = masklayer
    }
}

extension CGRect {
    init(x: CGFloat, y: CGFloat, size: CGFloat) {
        self.init(x: x, y: y, width: size, height: size)
    }
}

extension UIColor {
    class var random: UIColor {
        UIColor(red: CGFloat.random(in: 0..<1),
                                  green: CGFloat.random(in: 0..<1),
                                  blue: CGFloat.random(in: 0..<1),
                                  alpha: 1)
    }
}
