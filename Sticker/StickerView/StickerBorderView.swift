//
//  StickerBorderView.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/10.
//

import UIKit

class StickerBorderView: UIView {
    
    weak var parentVC: UIViewController?
    var delegate: StickerBorderDelegate?
    
    var contentBorderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    var deleteButton = IconButton(iconName: "icX")
    var rotateAndResizeButton = IconButton(iconName: "icTwoArrow")
    var topLeftButton = IconButton(iconName: "icArrowLeftTop")
    var bottomLeftButton = IconButton(iconName: "icArrowLeftBottom")
    var rotationButton = IconButton(iconName: "icRotate")
    
    let iconButtonLength: CGFloat = 48
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        initConstraints()
        initGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubViews() {
        addSubview(contentBorderView)
        addSubview(rotateAndResizeButton)
        addSubview(deleteButton)
        addSubview(topLeftButton)
        addSubview(bottomLeftButton)
        addSubview(rotationButton)
    }
    
    private func initConstraints() {
        contentBorderView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        rotateAndResizeButton.translatesAutoresizingMaskIntoConstraints = false
        topLeftButton.translatesAutoresizingMaskIntoConstraints = false
        bottomLeftButton.translatesAutoresizingMaskIntoConstraints = false
        rotationButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentBorderView.topAnchor.constraint(equalTo: topAnchor, constant: iconButtonLength / 2),
            contentBorderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: iconButtonLength / 2),
            contentBorderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(iconButtonLength / 2)),
            contentBorderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(iconButtonLength / 2)),
            
            deleteButton.topAnchor.constraint(equalTo: topAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: iconButtonLength),
            deleteButton.heightAnchor.constraint(equalToConstant: iconButtonLength),
            
            rotateAndResizeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            rotateAndResizeButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            rotateAndResizeButton.widthAnchor.constraint(equalToConstant: iconButtonLength),
            rotateAndResizeButton.heightAnchor.constraint(equalToConstant: iconButtonLength),
            
            topLeftButton.topAnchor.constraint(equalTo: topAnchor),
            topLeftButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            topLeftButton.widthAnchor.constraint(equalToConstant: iconButtonLength),
            topLeftButton.heightAnchor.constraint(equalToConstant: iconButtonLength),
            
            bottomLeftButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomLeftButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLeftButton.widthAnchor.constraint(equalToConstant: iconButtonLength),
            bottomLeftButton.heightAnchor.constraint(equalToConstant: iconButtonLength),
            
            rotationButton.topAnchor.constraint(equalTo: topAnchor),
            rotationButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            rotationButton.widthAnchor.constraint(equalToConstant: iconButtonLength),
            rotationButton.heightAnchor.constraint(equalToConstant: iconButtonLength),
        ])
    }
    
    private func initGesture() {
        addPanGesture(self, action: #selector(drag))
    }
    
    private func addPanGesture(_ view: UIView, action: Selector) {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: action)
        view.addGestureRecognizer(gesture)
    }
    
    @objc func drag(_ recognizer: UIPanGestureRecognizer) {
        guard let parent = parentVC as? CanvasStickerVC else { return }
        
        let translation = recognizer.translation(in: parent.mainView.phoneImageView)
        let point = CGPoint(x: (recognizer.view?.center.x ?? 0) + translation.x,
                            y: (recognizer.view?.center.y ?? 0) + translation.y)
        
        recognizer.view?.center = point
        delegate?.setStickerViewPosition(center: point)
        
        recognizer.setTranslation(.zero, in: self)
    }
}
