//
//  MainTabBarController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 15/07/22.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    static let identifier = "MainTabBarController"
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        DashXUtils.trackEventClient()
        DashXUtils.client1.track("TestEventFromiOSApp")
    }
    
}
