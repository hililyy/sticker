//
//  StickerView.swift
//  Sticker
//
//  Created by 강조은 on 2023/10/30.
//

import UIKit

final class StickerView: UIView {
    
    private var contentsView = UIView()
    
    private var contentBorderView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()

    private var deleteButton = UIButton(type: .custom)
    private var rotationButton = UIButton(type: .custom)
    private var deleteImageView = UIImageView(image: UIImage(named: "icX"))
    private var rotationImageView = UIImageView(image: UIImage(named: "icTwoArrow"))
    
    weak var parentVC: UIViewController?
    var delegate: StickerDelegate?
    
    var initImageWidth: CGFloat = 0
    var initImageHeight: CGFloat = 0
    private var iconButtonLength: CGFloat = 48
    
    private var defaultMinimumSize: Int = 0
    private var defaultMaximumSize: Int = 0
    
    private var minimumSize: Int = 0 {
        willSet(newValue) {
            self.minimumSize = max(newValue, defaultMinimumSize)
        }
    }
    
    private var maximumSize: Int = 0 {
        willSet(newValue) {
            self.maximumSize = min(newValue, defaultMaximumSize)
        }
    }
    
    private var initialBounds: CGRect = .zero // 초기 뷰의 크기
    private var initialDistance: CGFloat = 0 // 초기 터치 위치와 뷰의 중심 사이의 거리
    private var deltaAngle: CGFloat = 0 // 현재 뷰의 회전 각도와 제스처의 각도 차이
    
    convenience init(contentsView: UIView) {
        self.init()
        self.contentsView = contentsView
        
        initalize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBorderView(isSelected: Bool) {
        contentBorderView.layer.borderColor = isSelected ? UIColor.white.cgColor : UIColor.clear.cgColor
        deleteButton.isHidden = !isSelected
        rotationButton.isHidden = !isSelected
    }
    
    @objc private func deleteImage() {
        guard let parent = parentVC as? MainViewController else { return }
        parent.selectedSticker?.removeFromSuperview()
    }
    
    @objc private func drag(_ recognizer: UIPanGestureRecognizer) {
        guard let parent = parentVC as? MainViewController else { return }
        let translation = recognizer.translation(in: parent.mainView.backgroundImageView)
        recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x ?? 0) + translation.x,
                                          y: (recognizer.view?.center.y ?? 0) + translation.y)
        recognizer.setTranslation(.zero, in: self)
        
        delegate?.selectSticker(stickerView: self)
    }
    
    @objc private func tap() {
        delegate?.selectSticker(stickerView: self)
    }
    
    @objc private func rotateAndResize(_ recognizer: UIPanGestureRecognizer) {
        let touchLocation = recognizer.location(in: superview) // 터치 위치 가져옴
        let center = self.center // 현재 뷰의 중심 위치
        
        switch recognizer.state {
            
        case .began:
            deltaAngle = CGFloat(atan2f(Float(touchLocation.y - center.y),
                                        Float(touchLocation.x - center.x))) - getAngle(transform)
            initialBounds = bounds
            initialDistance = getDistance(point1: center,
                                          point2: touchLocation)
            
        case .changed:
            let angle = atan2f(Float(touchLocation.y - center.y),
                               Float(touchLocation.x - center.x))
            let angleDiff = Float(deltaAngle) - angle // 초기 각도와 현재 각도의 차이 계산
            transform = CGAffineTransform(rotationAngle: CGFloat(-angleDiff))
            
            var scale = getDistance(point1: center,
                                    point2: touchLocation) / initialDistance
            let minimumScale = CGFloat(minimumSize) / min(initialBounds.size.width,
                                                          initialBounds.size.height)
            let maximumScale = CGFloat(maximumSize) / max(initialBounds.size.width,
                                                          initialBounds.size.height)
            scale = min(max(scale, minimumScale), maximumScale)
            
            let scaledBounds = getNewSize(initialBounds,
                                          wScale: scale,
                                          hScale: scale)
            
            deleteButton.frame = CGRect(x: contentBorderView.frame.origin.x + contentBorderView.frame.width - (iconButtonLength / 2),
                                        y: 0,
                                        width: iconButtonLength,
                                        height: iconButtonLength)
            
            rotationButton.frame = CGRect(x: contentBorderView.frame.width,
                                          y: contentBorderView.frame.height,
                                          width: iconButtonLength,
                                          height: iconButtonLength)
            bounds = scaledBounds
            setNeedsDisplay()
            
        default:
            break
        }
    }
    
    
    // 회전 각도 추출
    private func getAngle(_ t: CGAffineTransform) -> CGFloat {
        return atan2(t.b, t.a)
    }
    
    // 터치 이벤트에 따른 이미지 크기 계산
    private func getNewSize(_ rect: CGRect, wScale: CGFloat, hScale: CGFloat) -> CGRect {
        return CGRect(x: rect.origin.x,
                      y: rect.origin.y,
                      width: ((rect.size.width - iconButtonLength) * wScale) + iconButtonLength,
                      height: ((rect.size.height - iconButtonLength) * hScale) + iconButtonLength)
    }
    
    // 두 점 사이의 거리 (피타고라스)
    private func getDistance(point1:CGPoint, point2:CGPoint) -> CGFloat {
        let fx = point2.x - point1.x
        let fy = point2.y - point1.y
        return sqrt(fx * fx + fy * fy)
    }
}

// MARK: - UI

extension StickerView {
    private func initalize() {
        initSubViews()
        initConstraints()
        initGesture()
        initTarget()
    }
    
    private func initSubViews() {
        addSubview(contentBorderView)
        contentBorderView.addSubview(contentsView)
        addSubview(rotationButton)
        addSubview(deleteButton)
        rotationButton.addSubview(rotationImageView)
        deleteButton.addSubview(deleteImageView)
    }
    
    private func initConstraints() {
        contentBorderView.translatesAutoresizingMaskIntoConstraints = false
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        rotationImageView.translatesAutoresizingMaskIntoConstraints = false
        deleteImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentBorderView.topAnchor.constraint(equalTo: contentsView.topAnchor),
            contentBorderView.leadingAnchor.constraint(equalTo: contentsView.leadingAnchor),
            contentBorderView.trailingAnchor.constraint(equalTo: contentsView.trailingAnchor),
            contentBorderView.bottomAnchor.constraint(equalTo: contentsView.bottomAnchor),
            
            contentsView.topAnchor.constraint(equalTo: topAnchor, constant: iconButtonLength / 2),
            contentsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: iconButtonLength / 2),
            contentsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(iconButtonLength / 2)),
            contentsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(iconButtonLength / 2)),
            
            rotationImageView.centerXAnchor.constraint(equalTo: rotationButton.centerXAnchor),
            rotationImageView.centerYAnchor.constraint(equalTo: rotationButton.centerYAnchor),
            rotationImageView.widthAnchor.constraint(equalToConstant: 24),
            rotationImageView.heightAnchor.constraint(equalToConstant: 24),
            
            deleteImageView.centerXAnchor.constraint(equalTo: deleteButton.centerXAnchor),
            deleteImageView.centerYAnchor.constraint(equalTo: deleteButton.centerYAnchor),
            deleteImageView.widthAnchor.constraint(equalToConstant: 24),
            deleteImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func initGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(drag))
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(tapGesture)
        
        let rotateAndResizeGesture = UIPanGestureRecognizer(target: self, action: #selector(rotateAndResize))
        rotationButton.addGestureRecognizer(rotateAndResizeGesture)
    }
    
    private func initTarget() {
        deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
    }
    
    func initFrame() {
        defaultMinimumSize = 30
        defaultMaximumSize = 1000
        minimumSize = defaultMinimumSize
        maximumSize = defaultMaximumSize
        
        guard let parent = parentVC as? MainViewController else { return }
        
        frame = CGRect(x: (parent.mainView.backgroundImageView.frame.width / 2) - (initImageWidth / 2),
                       y: (parent.mainView.backgroundImageView.frame.height / 2) - (initImageHeight / 2),
                       width: initImageWidth + iconButtonLength,
                       height: initImageHeight + iconButtonLength)
        
        deleteButton.frame = CGRect(x: initImageWidth,
                                    y: 0,
                                    width: iconButtonLength,
                                    height: iconButtonLength)
        
        rotationButton.frame = CGRect(x: initImageWidth,
                                      y: initImageHeight,
                                      width: iconButtonLength,
                                      height: iconButtonLength)
    }
}

protocol StickerDelegate {
    func selectSticker(stickerView: StickerView)
}
