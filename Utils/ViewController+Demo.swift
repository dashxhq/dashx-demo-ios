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
    
    func setupThemedNavigationBar(for mode: UIUserInterfaceStyle,
                                  isTranslucent: Bool = true) {
        let tintColor: UIColor = (mode == .dark) ? .white : .black
        let barTintColor: UIColor = (mode == .dark) ? .black : .white
        self.navigationController?.navigationBar.tintColor = tintColor
        self.navigationController?.navigationBar.barTintColor = barTintColor
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = isTranslucent
    }
    
    func showProgressView() {
        let progressView = ProgressView.init(frame: .zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: progressView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: progressView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        ])
        self.view.bringSubviewToFront(progressView)
    }
    
    func hideProgressView() {
        for subView in self.view.subviews {
            if subView.isKind(of: ProgressView.self) {
                subView.isHidden = true
                subView.removeFromSuperview()
            }
        }
    }
    
    func showError(with message: String?) {
        let errorAlertVC = UIAlertController(title: "Error", message: message ?? "Something went wrong", preferredStyle: .alert)
        errorAlertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in errorAlertVC.dismiss(animated: true)}))
        self.present(errorAlertVC, animated: true)
    }
    
    func showSuccess(with message: String) {
        let successAlertVC = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        successAlertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in successAlertVC.dismiss(animated: true)}))
        self.present(successAlertVC, animated: true)
    }
}
