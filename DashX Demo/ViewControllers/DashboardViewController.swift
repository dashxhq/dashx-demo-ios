//
//  DashboardViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 23/06/22.
//

import UIKit

class DashboardViewController: UIViewController {
    static let identifier = "DashboardViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupThemedNavigationBar()
    }
    
    @IBAction func onClickLogoutButton(_ sender: UIButton) {
        LocalStorage.instance.setUser(nil)
        
        let loginVC = UIViewController.instance(of: LoginViewController.identifier)
        let navVC = UINavigationController(rootViewController: loginVC)
        self.view.window?.rootViewController = navVC
    }
    
}
