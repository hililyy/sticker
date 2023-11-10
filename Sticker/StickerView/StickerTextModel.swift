//
//  StickerTextModel.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/10.
//

import Foundation

struct StickerTextModel {
    var text: String = ""
    var lastPosition: CGPoint = .zero
    var lastRotationAngle: CGFloat = 0
    var lastScale: CGFloat = 0
    var isEdit: Bool = false
}
