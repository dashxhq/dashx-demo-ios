//
//  ViewControllerHelper.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 23/06/22.
//

import UIKit

extension UIViewController {
    
    static func instance(of identifier: String, from storyboard: String = "Main") -> UIViewController {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    func setupThemedNavigationBar(tintColor: UIColor = .black,
                                  barTintColor: UIColor = .white,
                                  isTranslucent: Bool = true) {
        self.navigationController?.navigationBar.tintColor = tintColor
        self.navigationController?.navigationBar.barTintColor = barTintColor
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = isTranslucent
    }
    
}
