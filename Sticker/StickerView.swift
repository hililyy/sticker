//
//  StickerView.swift
//  Sticker
//
//  Created by 강조은 on 2023/10/30.
//

import UIKit

class StickerView: UIView {
    var contentsView = UIView()
    var parentVC: UIViewController?
    
    convenience init(contentsView: UIView, frame: CGRect) {
        self.init(frame: frame)
        self.contentsView = contentsView
        initalize()
        initConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initalize() {
        setGesture()
        contentsView.isUserInteractionEnabled = true
    }
    
    func setGesture() {
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(drag))
        self.addGestureRecognizer(panGesture)
    }
    
    @objc func drag(sender: UIPanGestureRecognizer) {
        let parent = parentVC as! MainViewController
        let translation = sender.translation(in: parent.mainView.backgroundImageView)
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(.zero, in: self)
    }
    
    func initConstraints() {
        addSubview(contentsView)
        
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentsView.topAnchor.constraint(equalTo: topAnchor),
            contentsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentsView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
