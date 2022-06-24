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
    
    // MARK: ViewModel
    struct ViewModel {
        var firstName: String = ""
        var lastName: String = ""
        var email: String = ""
        var password: String = ""
    }
    
    var viewModel: ViewModel = ViewModel()
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldListeners()
    }
    
    // MARK: Actions
    @IBAction func onClickRegister(_ sender: UIButton) {
        register()
    }
    
    @IBAction func onClickLogin(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func register() {
        /*
         Raise errors or Disable Register button when:
         viewModel.firstName.isEmpty &&
         viewModel.lastName.isEmpty &&
         !viewModel.email.isValidEmail() &&
         viewModel.password.isEmpty
         */
        
    }
    
    func setTextFieldListeners() {
        firstNameField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        lastNameField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        emailField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc
    func textFieldEditingChanged(_ textField: UITextField) {
        switch textField {
        case firstNameField:
            if let text = firstNameField.text {
                viewModel.firstName = text
            }
            break
        case lastNameField:
            if let text = lastNameField.text {
                viewModel.lastName = text
            }
            break
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

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameField:
            lastNameField.becomeFirstResponder()
            break
        case lastNameField:
            emailField.becomeFirstResponder()
            break
        case emailField:
            passwordField.becomeFirstResponder()
            break
        case passwordField:
            passwordField.resignFirstResponder()
            register()
            break
        default:
            break
        }
        return true
    }
}
