//
//  ProgressView.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 25/07/22.
//

import UIKit

class ProgressView: UIView {
    var activityIndicatorView: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpChildViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    func setUpChildViews() {
        self.backgroundColor = UIColor(named: "secondaryColorDisabled")
        
        activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        activityIndicatorView.color = UIColor(named: "primaryColor")
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicatorView)
        
        guard let activityIndicatorView = activityIndicatorView else { return }
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        self.bringSubviewToFront(activityIndicatorView)
    }
}
