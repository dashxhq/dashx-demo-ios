//
//  UpdateProfileViewController.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 10/07/22.
//

import UIKit

class UpdateProfileViewController: UIViewController {
    static let identifier = "UpdateProfileViewController"
    
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
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var updateProfileButton: UIButton! {
        didSet {
            updateProfileButton.isEnabled = false
            updateProfileButton.backgroundColor = UIColor(named: "primaryColorDisabled")
            updateProfileButton.setTitleColor(UIColor.white.withAlphaComponent(0.75), for: UIControl.State.disabled)
        }
    }
    
    private var formUtils: FormUtils!
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldListeners()
        populateProfileData()
        
        formUtils = FormUtils(fields: [firstNameField, lastNameField, emailField, updateProfileButton])
    }
    
    func populateProfileData() {
        if let localUser = LocalStorage.instance.getUser() {
            firstNameField.text = localUser.firstName
            lastNameField.text = localUser.lastName
            emailField.text = localUser.email
        }
    }
    
    // MARK: Actions
    @IBAction func onClickUpdateProfile(_ sender: UIButton) {
        performUpdateProfile()
    }
    
    func performUpdateProfile() {
        if !(emailField.text?.isValidEmail() ?? false) {
            errorLabel.text = "Please enter a valid email"
            return
        }
        
        setFormState(isEnabled: false)
        updateProfileButton.setTitle("Updating Profile", for: UIControl.State.disabled)
        
        APIClient.updateProfile(firstName: firstNameField.text!,
                               lastName: lastNameField.text!,
                               email: emailField.text!
                               ) { updatedProfileResponse in
            
            DispatchQueue.main.async {
                self.updateProfileButton.setTitle("Update Profile successful!", for: UIControl.State.disabled)
                
                LocalStorage.instance.setUser(updatedProfileResponse?.user)

                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } onError: { networkError in
            
            DispatchQueue.main.async {
                self.updateProfileButton.setTitle("Update Profile", for: UIControl.State.disabled)
                
                self.setFormState(isEnabled: true)
                self.errorLabel.text = networkError.message
            }
        }
    }
    
    func setFormState(isEnabled: Bool) {
        formUtils.setFieldsStatus(isEnabled: isEnabled)
    }
        
    func setTextFieldListeners() {
        firstNameField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        lastNameField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        emailField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc
    func textFieldEditingChanged(_ textField: UITextField) {
        if errorLabel.text != nil {
            errorLabel.text = ""
        }
        
        let registerButtonEnabled = [firstNameField,
                                     lastNameField,
                                     emailField
                                     ]
            .filter {$0.text?.isEmpty ?? true}
            .count == 0
        updateProfileButton.isEnabled = registerButtonEnabled
        updateProfileButton.backgroundColor = registerButtonEnabled ?
        UIColor(named: "primaryColor") : UIColor(named: "primaryColorDisabled")
    }
    
}

extension UpdateProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameField:
            lastNameField.becomeFirstResponder()
        case lastNameField:
            emailField.becomeFirstResponder()
        case emailField:
            performUpdateProfile()
        default:
            break
        }
        return true
    }
}
