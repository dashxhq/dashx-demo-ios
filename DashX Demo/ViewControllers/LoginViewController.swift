//
//  LoginViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 23/06/22.
//

import UIKit

class LoginViewController: UIViewController {
    static let identifier = "LoginViewController"
    
    // MARK: Outlets
    @IBOutlet weak var emailField: UITextField! {
        didSet {
            emailField.delegate = self
        }
    }
    
    @IBOutlet weak var passwordField: UITextField! {
        didSet {
            passwordField.delegate = self
        }
    }
    
    // MARK: ViewModel
    struct ViewModel {
        var email: String = ""
        var password: String = ""
    }
    
    var viewModel: ViewModel = ViewModel()
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldListeners()
        setupThemedNavigationBar()
    }
    
    // MARK: Actions
    @IBAction func onClickLogin(_ sender: UIButton) {
        login()
    }
    
    @IBAction func onClickRegister(_ sender: UIButton) {
        let registerVC = UIViewController.instance(of: RegisterViewController.identifier)
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func onClickForgotPassword(_ sender: UIButton) {
        
    }
    
    func login() {
        /*
         Raise errors or Disable Login button when:
         !viewModel.email.isValidEmail() &&
         viewModel.password.isEmpty
         */
        let dashboardVC = UIViewController.instance(of: DashboardViewController.identifier)
        let navVC = UINavigationController(rootViewController: dashboardVC)
        UIApplication.shared.windows.first?.rootViewController = navVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func setTextFieldListeners() {
        emailField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc
    func textFieldEditingChanged(_ textField: UITextField) {
        switch textField {
        case emailField:
            if let text = emailField.text {
                viewModel.email = text
            }
            break
        case passwordField:
            if let text = passwordField.text {
                viewModel.password = text
            }
            break
        default:
            break
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
            break
        case passwordField:
            passwordField.resignFirstResponder()
            login()
            break
        default:
            break
        }
        return true
    }
}
