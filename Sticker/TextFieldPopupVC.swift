//
//  TextFieldPopupVC.swift
//  Sticker
//
//  Created by 강조은 on 2023/11/07.
//

import UIKit

final class TextFieldPopupVC: UIViewController {
    
    // MARK: - Property
    
    let textFieldPopupView = TextFieldPopupView()
    var completeHandler: (String) -> () = { _ in }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = textFieldPopupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initalize()
    }
    
    // MARK: - Function
    
    @objc private func complete() {
        guard let contents = textFieldPopupView.contentsTextView.text else { return }
        
        if !contents.isEmpty {
//            dismissVC {
//                self.completeHandler(contents)
////                self.viewModel?.setSuggestData(contents: contents)
////                self.viewModel?.getSuggestDatas()
//            }
        }
    }
}

// MARK: - initalize

extension TextFieldPopupVC {
    private func initalize() {
        initTarget()
    }
    
    @objc func back() {
        dismiss(animated: true)
    }
    
    private func initTarget() {
        textFieldPopupView.backgroundButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        textFieldPopupView.completeButton.addTarget(self, action: #selector(complete), for: .touchUpInside)
    }
}
