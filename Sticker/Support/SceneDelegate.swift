//
//  SceneDelegate.swift
//  Sticker
//
//  Created by 강조은 on 2023/10/30.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = CanvasStickerVC()
        window.makeKeyAndVisible()
        self.window = window
    }
}
