//
//  StickerView.swift
//  Sticker
//
//  Created by 강조은 on 2023/10/30.
//

import UIKit

final class StickerView: UIView {
    
    // MARK: -  UI Property
    
    private var contentsView = UIView()
    
    private var contentBorderView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    private var deleteButton = IconButton(iconName: "icX")
    private var rotateAndResizeButton = IconButton(iconName: "icTwoArrow")
    private var topLeftButton = IconButton(iconName: "icArrowLeftTop")
    private var bottomLeftButton = IconButton(iconName: "icArrowLeftBottom")
    private var rotationButton = IconButton(iconName: "icRotate")
    
    // MARK: - Property
    
    weak var parentVC: UIViewController?
    var delegate: StickerDelegate?
    
    var type: StickerType = .image
    
    var stickerInfo = StickerTextModel()
    
    var initImageWidth: CGFloat = 0
    var initImageHeight: CGFloat = 0
    private var iconButtonLength: CGFloat = 48
    
    private var defaultMinimumSize: Int = 0
    private var defaultMaximumSize: Int = 0
    
    private var scale: CGFloat = .zero // 모종의 이유로 저장되지 않는 scale,,
    private var initialBounds: CGRect = .zero // 초기 뷰의 크기
    private var firstInitBounds: CGRect = .zero
    private var initialDistance: CGFloat = 0 // 초기 터치 위치와 뷰의 중심 사이의 거리
    private var deltaAngle: CGFloat = 0 // 현재 뷰의 회전 각도와 제스처의 각도 차이
    
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
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(contentsView: UIView) {
        self.init()
        self.contentsView = contentsView
        
        initalize()
    }
    
    // MARK: - Function
    
    func isHiddenBorderView(isSelected: Bool) {
        contentBorderView.layer.borderColor = isSelected ? UIColor.white.cgColor : UIColor.clear.cgColor
        deleteButton.isHidden = !isSelected
        rotateAndResizeButton.isHidden = !isSelected
        topLeftButton.isHidden = !isSelected
        bottomLeftButton.isHidden = !isSelected
        rotationButton.isHidden = !isSelected
    }
    
    private func setupIconButtonFrame(size: CGSize) {
        let width = size.width
        let height = size.height
        
        deleteButton.frame = CGRect(x: width,
                                    y: 0,
                                    size: iconButtonLength)
        
        rotateAndResizeButton.frame = CGRect(x: width,
                                             y: height,
                                             size: iconButtonLength)
        
        topLeftButton.frame = CGRect(x: 0,
                                     y: 0,
                                     size: iconButtonLength)
        
        bottomLeftButton.frame = CGRect(x: 0,
                                        y: height,
                                        size: iconButtonLength)
        
        rotationButton.frame = CGRect(x: width / 2,
                                      y: 0,
                                      size: iconButtonLength)
    }
    
    @objc private func deleteImage() {
        guard let parent = parentVC as? CanvasStickerVC else { return }
        parent.selectedSticker?.removeFromSuperview()
        parent.selectedSticker = nil
    }
}

// MARK: - Gesture Function
extension StickerView {
    @objc private func tap() {
        delegate?.selectSticker(stickerView: self)
        
        if type == .label {
            stickerInfo.lastPosition = self.center
            delegate?.tapLabelSticker(info: stickerInfo)
        }
    }
    
    @objc private func drag(_ recognizer: UIPanGestureRecognizer) {
        guard let parent = parentVC as? CanvasStickerVC else { return }
        
        let translation = recognizer.translation(in: parent.mainView.backgroundImageView)
        recognizer.view?.center = CGPoint(x: (recognizer.view?.center.x ?? 0) + translation.x,
                                          y: (recognizer.view?.center.y ?? 0) + translation.y)
        
        stickerInfo.lastPosition = CGPoint(x: (recognizer.view?.center.x ?? 0) + translation.x,
                               y: (recognizer.view?.center.y ?? 0) + translation.y)
        recognizer.setTranslation(.zero, in: self)
        
        delegate?.selectSticker(stickerView: self)
        
        if type == .label {
            stickerInfo.lastPosition = self.center
            delegate?.tapLabelSticker(info: stickerInfo)
        }
    }
    
    @objc private func rotateAndResize(_ recognizer: UIPanGestureRecognizer) {
        let touchLocation = recognizer.location(in: superview)
        let center = self.center
        
        switch recognizer.state {
            
        case .began:
            beganRotate(touchLocation: touchLocation)
            beganResize(touchLocation: touchLocation)
            
        case .changed:
            changeRotate(touchLocation: touchLocation, center: center)
            scale = changeResize(touchLocation: touchLocation, center: center)
            
            setNeedsDisplay()
            
        case .ended:
            let lastScale = stickerInfo.lastScale
            stickerInfo.lastScale = lastScale == 0 ? scale : lastScale * scale
            
            sendLabelInfoToVC()
            
        default:
            break
        }
    }
    
    @objc func rotation(_ recognizer: UIRotationGestureRecognizer) {
        let touchLocation = recognizer.location(in: superview)
        let center = self.center
        
        switch recognizer.state {
            
        case .began:
            beganRotate(touchLocation: touchLocation)
            
        case .changed:
            changeRotate(touchLocation: touchLocation, center: center)
            setNeedsDisplay()
            
        case .ended:
            sendLabelInfoToVC()
            
        default:
            break
        }
    }
    
    @objc private func resize(_ recognizer: UIPanGestureRecognizer) {
        let touchLocation = recognizer.location(in: superview)
        let center = self.center
        
        switch recognizer.state {
            
        case .began:
            beganResize(touchLocation: touchLocation)
            
        case .changed:
            scale = changeResize(touchLocation: touchLocation, center: center)
            setNeedsDisplay()
            
        case .ended:
            let lastScale = stickerInfo.lastScale
            stickerInfo.lastScale = lastScale == 0 ? scale : lastScale * scale
            
            sendLabelInfoToVC()
            
        default:
            break
        }
    }
    
    private func sendLabelInfoToVC() {
        if type == .label {
            stickerInfo.lastPosition = self.center
            delegate?.tapLabelSticker(info: stickerInfo)
        }
    }
}

// MARK: - in progress gesture Function
extension StickerView {
    private func beganRotate(touchLocation: CGPoint) {
        deltaAngle = CGFloat(atan2f(Float(touchLocation.y - center.y),
                                    Float(touchLocation.x - center.x))) - getAngle(transform)
    }
    
    private func changeRotate(touchLocation: CGPoint, center: CGPoint) {
        let angle = atan2f(Float(touchLocation.y - center.y),
                           Float(touchLocation.x - center.x))
        let angleDiff = Float(deltaAngle) - angle // 초기 각도와 현재 각도의 차이 계산
        stickerInfo.lastRotationAngle = CGFloat(angleDiff)
        transform = CGAffineTransform(rotationAngle: CGFloat(-angleDiff))
        
        setupIconButtonFrame(size: contentBorderView.frame.size)
    }
    
    private func beganResize(touchLocation: CGPoint) {
        initialBounds = bounds
        initialDistance = getDistance(point1: center,
                                      point2: touchLocation)
    }
    
    private func changeResize(touchLocation: CGPoint, center: CGPoint) -> CGFloat {
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
        
        setupIconButtonFrame(size: contentsView.frame.size)
        
        bounds = scaledBounds
        return scale
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


// MARK: - UI Init
extension StickerView {
    func initFrame() {
        defaultMinimumSize = 50
        defaultMaximumSize = 1000
        minimumSize = defaultMinimumSize
        maximumSize = defaultMaximumSize
        
        guard let parent = parentVC as? CanvasStickerVC else { return }
        
        let centerX = (parent.mainView.backgroundImageView.frame.width - (initImageWidth + iconButtonLength)) / 2
        let centerY = (parent.mainView.backgroundImageView.frame.height - (initImageHeight + iconButtonLength)) / 2
        
        frame = CGRect(x: centerX,
                       y: centerY,
                       width: initImageWidth + iconButtonLength,
                       height: initImageHeight + iconButtonLength)
        
        setupIconButtonFrame(size: CGSize(width: initImageWidth,
                                          height: initImageHeight))
        firstInitBounds = bounds
        
        if stickerInfo.isEdit {
            center = stickerInfo.lastPosition
            transform = CGAffineTransform(rotationAngle: CGFloat(-stickerInfo.lastRotationAngle))
            let scaledBounds = getNewSize(bounds,
                                          wScale: stickerInfo.lastScale,
                                          hScale: stickerInfo.lastScale)
            setupIconButtonFrame(size: CGSize(width: scaledBounds.size.width - iconButtonLength, height: scaledBounds.size.height - iconButtonLength) )
            bounds = scaledBounds
        }
    }
}

// MARK: - Initalize Function
extension StickerView {
    private func initalize() {
        initSubViews()
        initConstraints()
        initTarget()
        initGesture()
    }
    
    private func initSubViews() {
        addSubview(contentBorderView)
        contentBorderView.addSubview(contentsView)
        addSubview(rotateAndResizeButton)
        addSubview(deleteButton)
        addSubview(topLeftButton)
        addSubview(bottomLeftButton)
        addSubview(rotationButton)
    }
    
    private func initConstraints() {
        contentBorderView.translatesAutoresizingMaskIntoConstraints = false
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentBorderView.topAnchor.constraint(equalTo: contentsView.topAnchor),
            contentBorderView.leadingAnchor.constraint(equalTo: contentsView.leadingAnchor),
            contentBorderView.trailingAnchor.constraint(equalTo: contentsView.trailingAnchor),
            contentBorderView.bottomAnchor.constraint(equalTo: contentsView.bottomAnchor),
            
            contentsView.topAnchor.constraint(equalTo: topAnchor, constant: iconButtonLength / 2),
            contentsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: iconButtonLength / 2),
            contentsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(iconButtonLength / 2)),
            contentsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(iconButtonLength / 2)),
        ])
    }
    
    private func initTarget() {
        deleteButton.addTarget(self,
                               action: #selector(deleteImage),
                               for: .touchUpInside)
    }
    
    private func initGesture() {
        addTapGesture(self, action: #selector(tap))
        addPanGesture(self, action: #selector(drag))
        addPanGesture(rotateAndResizeButton, action: #selector(rotateAndResize))
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
}
