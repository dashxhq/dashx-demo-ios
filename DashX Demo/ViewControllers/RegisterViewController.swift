//
//  RegisterViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 23/06/22.
//

import UIKit

class RegisterViewController: UIViewController {
    static let identifier = "RegisterViewController"
    
    // MARK: Outlets
    @IBOutlet weak var firstNameField: UITextField! {
        didSet {
            firstNameField.delegate = self
        }
    }
    
    @IBOutlet weak var lastNameField: UITextField! {
        didSet {
            lastNameField.delegate = self
        }
    }
    
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
    @IBOutlet weak var registerButton: UIButton! {
        didSet {
            registerButton.isEnabled = false
            registerButton.backgroundColor = UIColor(named: "primaryColorDisabled")
            registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.75), for: UIControl.State.disabled)
        }
    }
    
    private var formUtils: FormUtils!
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldListeners()
        
        formUtils = FormUtils(fields: [firstNameField, lastNameField, emailField, passwordField, registerButton])
    }
    
    // MARK: Actions
    @IBAction func onClickRegister(_ sender: UIButton) {
        performRegistration()
    }
    
    @IBAction func onClickLogin(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func performRegistration() {
        if !(emailField.text?.isValidEmail() ?? false) {
            errorLabel.text = "Please enter a valid email"
            return
        }
        
        setFormState(isEnabled: false)
        registerButton.setTitle("Registering", for: UIControl.State.disabled)
        
        APIClient.registerUser(firstName: firstNameField.text!,
                               lastName: lastNameField.text!,
                               email: emailField.text!,
                               password: passwordField.text!) { _ in
            
            DispatchQueue.main.async {
                self.registerButton.setTitle("Registration successful!", for: UIControl.State.disabled)

                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } onError: { networkError in
            
            DispatchQueue.main.async {
                self.registerButton.setTitle("Register", for: UIControl.State.disabled)
                
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
        firstNameField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        lastNameField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        emailField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc
    func textFieldEditingChanged(_ textField: UITextField) {
        if errorLabel.text != nil {
            errorLabel.text = ""
        }
        
        let registerButtonEnabled = [firstNameField,
                                     lastNameField,
                                     emailField,
                                     passwordField]
            .filter {$0.text?.isEmpty ?? true}
            .count == 0
        registerButton.isEnabled = registerButtonEnabled
        registerButton.backgroundColor = registerButtonEnabled ?
        UIColor(named: "primaryColor") : UIColor(named: "primaryColorDisabled")
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameField:
            lastNameField.becomeFirstResponder()
        case lastNameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            passwordField.resignFirstResponder()
            performRegistration()
        default:
            break
        }
        return true
    }
}
