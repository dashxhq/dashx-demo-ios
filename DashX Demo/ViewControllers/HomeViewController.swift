//
//  DashboardViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 23/06/22.
//

import UIKit
import DashX

class HomeViewController: UIViewController {
    static let identifier = "DashboardViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupThemedNavigationBar()
        
        do {
            print("Sending event to DashX")
            DashXUtils.client1.track("TestEventFromiOSApp")
            DashXUtils.trackEventClient2()
            print("Sent event to DashX")
        } catch {
            print("DashXError: \(error)")
        }
    }
}
