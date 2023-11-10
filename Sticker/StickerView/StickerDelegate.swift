//
//  StickerDelegate.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/10.
//

import Foundation

protocol StickerDelegate {
    func selectSticker(stickerView: StickerView)
    func tapLabelSticker(info: StickerTextModel)
}
