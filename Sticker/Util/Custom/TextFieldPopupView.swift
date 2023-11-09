//
//  TextFieldPopupView.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/07.
//

import UIKit

final class TextFieldPopupView: UIView {
    
    // MARK: - UI components
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    
    lazy var backgroundButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        return button
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    let contentsTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 17)
        textView.textColor = .darkGray
        textView.layer.cornerRadius = 15
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 0)
        textView.becomeFirstResponder()
        return textView
    }()
    
    let completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("추가", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = .yellow
        button.layer.cornerRadius = 10
        return button
    }()
    
    // MARK: - Functions
    
    func setCompleteButtonEnable(_ isEnabled: Bool) {
        completeButton.isEnabled = isEnabled
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constraint
    
    func initSubviews() {
        addSubview(backgroundView)
        addSubview(backgroundButton)
        addSubview(containerView)
        containerView.addSubview(contentsTextView)
        containerView.addSubview(completeButton)
    }
    
    func initConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentsTextView.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            backgroundButton.topAnchor.constraint(equalTo: topAnchor),
            backgroundButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 180),
            
            contentsTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            contentsTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            contentsTextView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentsTextView.heightAnchor.constraint(equalToConstant: 60),
            
            completeButton.leadingAnchor.constraint(equalTo: contentsTextView.leadingAnchor),
            completeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25),
            completeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            completeButton.heightAnchor.constraint(equalToConstant: 45),
        ])
    }
}
