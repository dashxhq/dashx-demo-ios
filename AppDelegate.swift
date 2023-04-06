//
//  AppDelegate.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 23/06/22.
//

import DashX
import FirebaseCore
import FirebaseMessaging
import UIKit

@main
class AppDelegate: DashXAppDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Optional: Enable logs for troubleshooting
        DashXLog.setLogLevel(to: .debug)

        // Configure DashX
        DashX.configure(
            withPublicKey: try! Configuration.value(for: "DASHX_PUBLIC_KEY"),
            baseURI: try? Configuration.value(for: "DASHX_BASE_URI"),
            targetEnvironment: try? Configuration.value(for: "DASHX_TARGET_ENVIRONMENT")
        )

        // Configure FCM
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration
    {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running,
        // this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
