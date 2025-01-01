//
//  SceneDelegate.swift
//  final
//
//  Created by Sara Khalaf on 01/12/2024.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userUID = UserDefaults.standard.string(forKey: "user_uid_key")
        
        var initialViewController: UIViewController
        
        if let uid = userUID, !uid.isEmpty {
            // User is logged in, present the appropriate view controller
            let email = Auth.auth().currentUser?.email ?? ""
            if email.contains("@bevent.admin") {
                initialViewController = storyboard.instantiateViewController(withIdentifier: "AdminTabBarController")
            } else if email.contains("@bevent.organizer") {
                initialViewController = storyboard.instantiateViewController(withIdentifier: "EventTabBarController")
            } else {
                initialViewController = storyboard.instantiateViewController(withIdentifier: "AttendeeTabBarController")
            }
        } else {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginT")
        }
        
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Undo changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save data, release shared resources, and store enough scene-specific state information.
    }
}
