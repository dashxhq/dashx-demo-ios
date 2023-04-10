//
//  LoginViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 23/06/22.
//

import DashX
import UIKit

class LoginViewController: UIViewController {
    static let identifier = "LoginViewController"

    // MARK: Outlets

    @IBOutlet var emailField: UITextField! {
        didSet {
            emailField.delegate = self
        }
    }

    @IBOutlet var passwordField: UITextField! {
        didSet {
            passwordField.delegate = self
        }
    }

    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var loginButton: UIButton! {
        didSet {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(named: "primaryColorDisabled")
            loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.75), for: UIControl.State.disabled)
        }
    }

    @IBOutlet var registerButton: UIButton! {
        didSet {
            registerButton.titleLabel?.textColor = UIColor(named: "primaryColor")
            registerButton.layer.borderColor = UIColor(named: "primaryColor")?.cgColor
            registerButton.layer.borderWidth = 1
        }
    }

    @IBOutlet var contactUsButton: UIButton! {
        didSet {
            contactUsButton.titleLabel?.textColor = UIColor(named: "primaryColor")
        }
    }

    private var formUtils: FormUtils!

    // MARK: ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldListeners()
        formUtils = FormUtils(fields: [emailField, passwordField, loginButton])
    }

    // MARK: ViewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
    }

    // MARK: Actions

    @IBAction func onClickLogin(_ sender: UIButton) {
        performLogin()
    }

    @IBAction func onClickRegister(_ sender: UIButton) {
        let registerVC = UIViewController.instance(of: RegisterViewController.identifier)
        navigationController?.pushViewController(registerVC, animated: true)
    }

    @IBAction func onClickForgotPassword(_ sender: UIButton) {
        let forgotPasswordVC = UIViewController.instance(of: ForgotPasswordViewController.identifier)
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }

    @IBAction func onClickContactUs(_ sender: UIButton) {
        let contactUsVC = UIViewController.instance(of: ContactUsViewController.identifier)
        navigationController?.pushViewController(contactUsVC, animated: true)
    }

    func performLogin() {
        if !(emailField.text?.isValidEmail() ?? false) {
            errorLabel.text = "Please enter a valid email"
            return
        }

        setFormState(isEnabled: false)
        loginButton.setTitle("Logging in", for: UIControl.State.disabled)

        APIClient.loginUser(email: emailField.text!, password: passwordField.text!) { response in
            self.persistDashXData(response!)

            // Call track event after DashX.setIdentity within persistDashXData
            // This ensures that track calls are made for the logged in user
            DashX.track("Login Succeeded")

            DispatchQueue.main.async {
                self.goToTabBarScreen()
            }
        } onError: { networkError in
            DashX.track("Login Failed")

            DispatchQueue.main.async {
                self.loginButton.setTitle("Login", for: UIControl.State.disabled)

                self.setFormState(isEnabled: true)
                self.errorLabel.text = networkError.message
            }
        }
    }

    func persistDashXData(_ response: LoginResponse) {
        if let decodedToken = response.decodedToken,
           let dashXToken = response.dashXToken,
           let user = decodedToken.user,
           let userId = user.idString
        {
            LocalStorage.instance.setUser(user)
            LocalStorage.instance.setDashXToken(dashXToken)
            LocalStorage.instance.setToken(response.token)

            DashX.setIdentity(uid: userId, token: dashXToken)

            DashX.requestNotificationPermission { authorizationStatus in
                switch authorizationStatus {
                case .authorized:
                    DashX.subscribe()
                default:
                    print("permission denied to send push notifications")
                }
            }
        }
    }

    func setFormState(isEnabled: Bool) {
        formUtils.setFieldsStatus(isEnabled: isEnabled)
    }

    func goToTabBarScreen() {
        let tabBarVC = UIViewController.instance(of: MainTabBarController.identifier)
        UIApplication.shared.windows.first?.rootViewController = tabBarVC
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
