//
//  Extension.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/07.
//

import UIKit

extension UIView {
    func mergeImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        self.superview!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func mask(rect: CGRect) {
        // 1. path 인스턴스로 경로 정보 획득
        let path = CGMutablePath()
        path.addRect(rect)
        
        // 2. CAShapeLayer 인스턴스에 위 path 인스턴스 사용
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        
        // 3. mask에 shapeLayer 인스턴스 사용
        layer.mask = shapeLayer
    }
}

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
            context.fill(self.bounds)
            layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
}

extension CGRect {
    init(x: CGFloat, y: CGFloat, size: CGFloat) {
        self.init(x: x, y: y, width: size, height: size)
    }
}
