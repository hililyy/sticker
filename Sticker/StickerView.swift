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
    private var resizeButton = UIButton(type: .custom)
    private var topLeftButton = UIButton(type: .custom)
    private var bottomLeftButton = UIButton(type: .custom)
    private var rotationButton = UIButton(type: .custom)
    
    private var deleteImageView = UIImageView(image: UIImage(named: "icX"))
    private var resizeImageView = UIImageView(image: UIImage(named: "icTwoArrow"))
    private var topLeftImageView = UIImageView(image: UIImage(named: "icArrowLeftTop"))
    private var bottomLeftImageView = UIImageView(image: UIImage(named: "icArrowLeftBottom"))
    private var rotationImageView = UIImageView(image: UIImage(named: "icRotate"))
    
    weak var parentVC: UIViewController?
    var delegate: StickerDelegate?
    
    var initImageWidth: CGFloat = 0
    var initImageHeight: CGFloat = 0
    private var iconButtonLength: CGFloat = 48
    
    private var defaultMinimumSize: Int = 0
    private var defaultMaximumSize: Int = 0
    
    private var minimumSize: Int = 0 {
        didSet {
            self.minimumSize = max(minimumSize, defaultMinimumSize)
        }
    }
    
    private var maximumSize: Int = 0 {
        didSet {
            self.maximumSize = min(maximumSize, defaultMaximumSize)
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
        resizeButton.isHidden = !isSelected
        topLeftButton.isHidden = !isSelected
        bottomLeftButton.isHidden = !isSelected
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
            setupIconButtonFrame(size: contentBorderView.frame.size)
            
            bounds = scaledBounds
            setNeedsDisplay()
            
        default:
            break
        }
    }
    
    @objc private func resize(_ recognizer: UIPanGestureRecognizer) {
        let touchLocation = recognizer.location(in: superview) // 터치 위치 가져옴
        let center = self.center // 현재 뷰의 중심 위치
        
        switch recognizer.state {
            
        case .began:
            initialBounds = bounds
            initialDistance = getDistance(point1: center,
                                          point2: touchLocation)
            
        case .changed:
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
            
            setupIconButtonFrame(size: contentBorderView.frame.size)
            
            bounds = scaledBounds
            setNeedsDisplay()
            
        default:
            break
        }
    }
    
    @objc func rotation(_ recognizer: UIRotationGestureRecognizer) {
        let touchLocation = recognizer.location(in: superview) // 터치 위치 가져옴
        let center = self.center // 현재 뷰의 중심 위치
        
        switch recognizer.state {
            
        case .began:
            deltaAngle = CGFloat(atan2f(Float(touchLocation.y - center.y),
                                        Float(touchLocation.x - center.x))) - getAngle(transform)
            
        case .changed:
            let angle = atan2f(Float(touchLocation.y - center.y),
                               Float(touchLocation.x - center.x))
            let angleDiff = Float(deltaAngle) - angle // 초기 각도와 현재 각도의 차이 계산
            transform = CGAffineTransform(rotationAngle: CGFloat(-angleDiff))
            
            setupIconButtonFrame(size: contentBorderView.frame.size)
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
        addSubview(resizeButton)
        addSubview(deleteButton)
        addSubview(topLeftButton)
        addSubview(bottomLeftButton)
        addSubview(rotationButton)
        resizeButton.addSubview(resizeImageView)
        deleteButton.addSubview(deleteImageView)
        topLeftButton.addSubview(topLeftImageView)
        bottomLeftButton.addSubview(bottomLeftImageView)
        rotationButton.addSubview(rotationImageView)
    }
    
    private func initConstraints() {
        contentBorderView.translatesAutoresizingMaskIntoConstraints = false
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        resizeImageView.translatesAutoresizingMaskIntoConstraints = false
        deleteImageView.translatesAutoresizingMaskIntoConstraints = false
        topLeftImageView.translatesAutoresizingMaskIntoConstraints = false
        bottomLeftImageView.translatesAutoresizingMaskIntoConstraints = false
        rotationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentBorderView.topAnchor.constraint(equalTo: contentsView.topAnchor),
            contentBorderView.leadingAnchor.constraint(equalTo: contentsView.leadingAnchor),
            contentBorderView.trailingAnchor.constraint(equalTo: contentsView.trailingAnchor),
            contentBorderView.bottomAnchor.constraint(equalTo: contentsView.bottomAnchor),
            
            contentsView.topAnchor.constraint(equalTo: topAnchor, constant: iconButtonLength / 2),
            contentsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: iconButtonLength / 2),
            contentsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(iconButtonLength / 2)),
            contentsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(iconButtonLength / 2)),
            
            resizeImageView.centerXAnchor.constraint(equalTo: resizeButton.centerXAnchor),
            resizeImageView.centerYAnchor.constraint(equalTo: resizeButton.centerYAnchor),
            resizeImageView.widthAnchor.constraint(equalToConstant: 24),
            resizeImageView.heightAnchor.constraint(equalToConstant: 24),
            
            deleteImageView.centerXAnchor.constraint(equalTo: deleteButton.centerXAnchor),
            deleteImageView.centerYAnchor.constraint(equalTo: deleteButton.centerYAnchor),
            deleteImageView.widthAnchor.constraint(equalToConstant: 24),
            deleteImageView.heightAnchor.constraint(equalToConstant: 24),
            
            topLeftImageView.centerXAnchor.constraint(equalTo: topLeftButton.centerXAnchor),
            topLeftImageView.centerYAnchor.constraint(equalTo: topLeftButton.centerYAnchor),
            topLeftImageView.widthAnchor.constraint(equalToConstant: 24),
            topLeftImageView.heightAnchor.constraint(equalToConstant: 24),
            
            bottomLeftImageView.centerXAnchor.constraint(equalTo: bottomLeftButton.centerXAnchor),
            bottomLeftImageView.centerYAnchor.constraint(equalTo: bottomLeftButton.centerYAnchor),
            bottomLeftImageView.widthAnchor.constraint(equalToConstant: 24),
            bottomLeftImageView.heightAnchor.constraint(equalToConstant: 24),
            
            rotationImageView.centerXAnchor.constraint(equalTo: rotationButton.centerXAnchor),
            rotationImageView.centerYAnchor.constraint(equalTo: rotationButton.centerYAnchor),
            rotationImageView.widthAnchor.constraint(equalToConstant: 24),
            rotationImageView.heightAnchor.constraint(equalToConstant: 24)
            
        ])
    }
    
    private func initGesture() {
        addTapGesture(self, action: #selector(tap))
        addPanGesture(self, action: #selector(drag))
        addPanGesture(resizeButton, action: #selector(rotateAndResize))
        addPanGesture(rotationButton, action: #selector(rotation))
        addPanGesture(topLeftButton, action: #selector(resize))
        addPanGesture(bottomLeftButton, action: #selector(resize))
    }
    
    private func addPanGesture(_ view: UIView, action: Selector) {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: action)
        view.addGestureRecognizer(gesture)
    }
    
    private func addTapGesture(_ view: UIView, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: action)
        addGestureRecognizer(tapGesture)
    }
    
    private func setupIconButtonFrame(size: CGSize) {
        let width = size.width
        let height = size.height
        
        deleteButton.frame = CGRect(x: width,
                                    y: 0,
                                    width: iconButtonLength,
                                    height: iconButtonLength)
        
        resizeButton.frame = CGRect(x: width,
                                    y: height,
                                    width: iconButtonLength,
                                    height: iconButtonLength)
        
        topLeftButton.frame = CGRect(x: 0,
                                     y: 0,
                                     width: iconButtonLength,
                                     height: iconButtonLength)
        
        bottomLeftButton.frame = CGRect(x: 0,
                                        y: height,
                                        width: iconButtonLength,
                                        height: iconButtonLength)
        
        rotationButton.frame = CGRect(x: width / 2,
                                      y: 0,
                                      width: iconButtonLength,
                                      height: iconButtonLength)
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
        
        let centerX = (parent.mainView.backgroundImageView.frame.width - (initImageWidth + iconButtonLength)) / 2
        let centerY = (parent.mainView.backgroundImageView.frame.height - (initImageHeight + iconButtonLength)) / 2
        
        frame = CGRect(x: centerX,
                       y: centerY,
                       width: initImageWidth + iconButtonLength,
                       height: initImageHeight + iconButtonLength)
        
        setupIconButtonFrame(size: CGSize(width: initImageWidth,
                                          height: initImageHeight))
    }
}

protocol StickerDelegate {
    func selectSticker(stickerView: StickerView)
}
