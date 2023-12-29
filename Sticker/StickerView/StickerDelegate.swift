//
//  StickerDelegate.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/10.
//

import Foundation

protocol StickerDelegate {
    func tapLabelSticker(info: StickerTextModel)
    func selectSticker(stickerView: StickerView)
    func setBorderViewPosition(frame: CGRect, bounds: CGRect)
    func setBorderViewRotation(angle: CGFloat)
}

protocol StickerBorderDelegate {
    func setStickerViewPosition(center: CGPoint)
}
