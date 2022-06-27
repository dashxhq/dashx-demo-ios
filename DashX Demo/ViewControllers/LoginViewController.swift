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
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(named: "primaryColorDisabled")
            loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.75), for: UIControl.State.disabled)
        }
    }
    
    private var formUtils: FormUtils!
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldListeners()
        setupThemedNavigationBar()
        
        formUtils = FormUtils(fields: [emailField, passwordField, loginButton])
    }
    
    // MARK: Actions
    @IBAction func onClickLogin(_ sender: UIButton) {
        performLogin()
    }
    
    @IBAction func onClickRegister(_ sender: UIButton) {
        let registerVC = UIViewController.instance(of: RegisterViewController.identifier)
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func onClickForgotPassword(_ sender: UIButton) {
        // No op for now
    }
    
    func performLogin() {
        if !(emailField.text?.isValidEmail() ?? false) {
            errorLabel.text = "Please enter a valid email"
            return
        }
        
        setFormState(isEnabled: false)
        loginButton.setTitle("Logging in", for: UIControl.State.disabled)
        
        APIClient.loginUser(email: emailField.text!, password: passwordField.text!) { _ in
            DispatchQueue.main.async {
                self.goToDashboardScreen()
            }
        } onError: { networkError in
            DispatchQueue.main.async {
                self.loginButton.setTitle("Login", for: UIControl.State.disabled)
                
                self.setFormState(isEnabled: true)
                self.errorLabel.text = networkError.message
            }
        }
    }
    
    func setFormState(isEnabled: Bool) {
        formUtils.setFieldsStatus(isEnabled: isEnabled)
    }
    
    func goToDashboardScreen() {
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
        if errorLabel.text != nil {
            errorLabel.text = ""
        }
        
        let registerButtonEnabled = [emailField,
                                     passwordField].filter { $0.text?.isEmpty ?? true }.count == 0
        loginButton.isEnabled = registerButtonEnabled
        loginButton.backgroundColor = registerButtonEnabled ?
        UIColor(named: "primaryColor") : UIColor(named: "primaryColorDisabled")
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            passwordField.resignFirstResponder()
            performLogin()
        default:
            break
        }
        return true
    }
}
