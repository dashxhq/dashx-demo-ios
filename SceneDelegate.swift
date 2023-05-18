//
//  SceneDelegate.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 23/06/22.
//

import DashX
import UIKit

class SceneDelegate: DashXSceneDelegate {
    var window: UIWindow?
    private let dashxSceneDelegateBase = DashXSceneDelegate()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if (scene as? UIWindowScene) == nil {
            return
        }

        UIApplication.shared.addTapGestureRecognizer()
        self.checkStoredUserAndNavigate()

        DashX.handleUserActivity(userActivity: connectionOptions.userActivities.first)
    }

    func checkStoredUserAndNavigate() {
        if LocalStorage.instance.getUser() != nil {
            // User exists, go to Dashboard/Home
            let tabBarVC = UIViewController.instance(of: MainTabBarController.identifier)
            self.window?.rootViewController = tabBarVC
        } else {
            // Open login screen
            let loginVC = UIViewController.instance(of: LoginViewController.identifier)
            let navVC = UINavigationController(rootViewController: loginVC)
            self.window?.rootViewController = navVC
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded
        // (see `application:didDiscardSceneSessions` instead).
    }

    override func sceneDidBecomeActive(_ scene: UIScene) {
        // Call DashXSceneDelegate's sceneDidBecomeActive
        super.sceneDidBecomeActive(scene)

        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        DashX.handleUserActivity(userActivity: userActivity)
    }
}
