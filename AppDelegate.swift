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
class AppDelegate: DashXAppDelegate, MessagingDelegate {
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

        // Allow tracking of app's lifecycle events
        DashX.enableLifecycleTracking()

        // Enable Ad-tracking for all events
        DashX.enableAdTracking()

        // Configure Firebase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        // Requesting Push Notifications Permission
        DashX.requestNotificationPermission { authorizationStatus in
            switch authorizationStatus {
            case .authorized:
                print("permission authorized to receive push notifications")
            default:
                print("permission denied to receive push notifications")
            }
        }

        return true
    }

    // MARK: - UISceneSession Lifecycle

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

    // MARK: - FCM Token management

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            print("FCM Token is empty")
            return
        }

        DashX.setFCMToken(to: token)
    }

    // MARK: - Push Notification Handlers

    override func notificationDeliveredInForeground(message: [AnyHashable: Any]) -> UNNotificationPresentationOptions {
        print("\n=== Notification Delivered In Foreground ===\n")
        print(message)
        print("\n=================================================\n")

        // This is how you want to show your notification in the foreground
        // You can pass "[]" to not show the notification to the user or
        // handle this with your own custom styles
        return [.sound, .alert, .badge]
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }

    override func notificationClicked(message: [AnyHashable: Any], actionIdentifier: String) {
        print("\n=== Notification Clicked ===\n")
        print(message)
        print("\n=================================\n")

        showAlert(title: "Notification Action", message: actionIdentifier)
    }

    override func handleLink(url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            // Extract any parameters from the URL if needed
            let path = String(components.path.dropFirst())

            // Define your view controllers
            let bookmarksViewController = UIViewController.instance(of: BookmarksListViewController.identifier)
            let forgotPasswordViewController = UIViewController.instance(of: ForgotPasswordViewController.identifier)

            let viewControllers = [
                "bookmarks": bookmarksViewController,
                "forgot-password": forgotPasswordViewController
            ]

            guard let targetViewController = viewControllers[path] else {
                print("This path cannot be handled")
                return
            }

            guard let window = UIApplication.shared.windows.first else {
                fatalError("No available windows")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                window.rootViewController = targetViewController
            }
        }
    }
}
