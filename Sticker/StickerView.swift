//
//  StickerView.swift
//  Sticker
//
//  Created by 강조은 on 2023/10/30.
//

import UIKit

final class StickerView: UIView {
    var contentsView = UIView()
    
    var contentBorderView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()

    var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icX"), for: .normal)
        button.frame = CGRect(x: 100 - 24, y: 0, width: 24, height: 24)
        return button
    }()
    
    var rotationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icTwoArrow"), for: .normal)
        button.frame = CGRect(x: 100 - 24, y: 100 - 24, width: 24, height: 24)
        return button
    }()
    
    var parentVC: UIViewController?
    
    var delegate: StickerDelegate?
    
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
        initGesture()
        initTarget()
    }
    var deleteHandler: () -> () = {}
    func initGesture() {
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(drag))
        self.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.addGestureRecognizer(tapGesture)
    }
    
    func initTarget() {
        deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
    }
    
    func setBorderView(isSelected: Bool) {
        contentBorderView.layer.borderColor = isSelected ? UIColor.white.cgColor : UIColor.clear.cgColor
        deleteButton.isHidden = !isSelected
        rotationButton.isHidden = !isSelected
    }
    
    @objc func deleteImage(sender: UIButton) {
        deleteHandler()
    }
    
    @objc func drag(sender: UIPanGestureRecognizer) {
        let parent = parentVC as! MainViewController
        let translation = sender.translation(in: parent.mainView.backgroundImageView)
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(.zero, in: self)
    }
    
    @objc func tap() {
        print("탭")
        delegate?.tapSticker(stickerView: self)
        
    }
    
    func initConstraints() {
        addSubview(contentBorderView)
        contentBorderView.addSubview(contentsView)
        addSubview(rotationButton)
        addSubview(deleteButton)
        
        contentBorderView.translatesAutoresizingMaskIntoConstraints = false
        contentsView.translatesAutoresizingMaskIntoConstraints = false
//        rotationButton.translatesAutoresizingMaskIntoConstraints = false
//        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentBorderView.topAnchor.constraint(equalTo: contentsView.topAnchor),
            contentBorderView.leadingAnchor.constraint(equalTo: contentsView.leadingAnchor),
            contentBorderView.trailingAnchor.constraint(equalTo: contentsView.trailingAnchor),
            contentBorderView.bottomAnchor.constraint(equalTo: contentsView.bottomAnchor),
            
            contentsView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            contentsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            contentsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            contentsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
//            rotationButton.widthAnchor.constraint(equalToConstant: 24),
//            rotationButton.heightAnchor.constraint(equalToConstant: 24),
        ])
    }
}


protocol StickerDelegate {
    func tapSticker(stickerView: StickerView)
}
