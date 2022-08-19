//
//  UpdateProfileViewController.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 10/07/22.
//

import UIKit
import DashX

class UpdateProfileViewController: UIViewController {
    static let identifier = "UpdateProfileViewController"
    
    // MARK: Outlets
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        }
    }
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
    
    var imagePickerVC: UIImagePickerController {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        return imagePickerVC
    }
    
    var localUser: User?
    private var formUtils: FormUtils!
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldListeners()
        populateProfileData()
        
        formUtils = FormUtils(fields: [firstNameField, lastNameField, emailField, updateProfileButton])
    }
    
    // MARK: TraitCollectionDidChange
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
    }
    
    func populateProfileData() {
        if let localUser = self.localUser {
            firstNameField.text = localUser.firstName
            lastNameField.text = localUser.lastName
            emailField.text = localUser.email
        }
    }
    
    // MARK: Actions
    @IBAction func onClickUpdateAvatar(_ sender: Any) {
        performUpdateAvatar()
    }
    @IBAction func onClickUpdateProfile(_ sender: UIButton) {
        performUpdateProfile()
    }
    
    func performUpdateAvatar() {
        present(imagePickerVC, animated: true)
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

extension UpdateProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage,
           let imageURL = info[.imageURL] as? URL {
            avatarImageView.image = image
            showProgressView()
            DashX.uploadExternalAsset(fileURL: imageURL, externalColumnId: "e8b7b42f-1f23-431c-b739-9de0fba3dadf") { response in
                DispatchQueue.main.async {
                    self.hideProgressView()
                    if let jsonDictionary = response.jsonValue as? [String: Any] {
                        do {
                            let json = try JSONSerialization.data(withJSONObject: jsonDictionary)
                            let preferenceData = try JSONDecoder().decode(PrepareExternalAssetResponse.self, from: json)
                            // Pass status and URL to "avatar"
                            print(preferenceData)
                        } catch {
                            self.showError(with: error.localizedDescription)
                        }
                    } else {
                        self.showError(with: "Stored preferences response is empty.")
                    }
                }
            } failureCallback: { error in
                DispatchQueue.main.async {
                    self.hideProgressView()
                    self.showError(with: error.localizedDescription)
                }
            }
        }
    }
}
