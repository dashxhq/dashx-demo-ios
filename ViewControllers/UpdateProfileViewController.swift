//
//  UpdateProfileViewController.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 10/07/22.
//

import UIKit
import DashX
import PhotosUI
import AVFoundation

class UpdateProfileViewController: UIViewController {
    static let identifier = "UpdateProfileViewController"
    
    // MARK: Outlets
    @IBOutlet weak var avatarNameLabel: UILabel!
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
    
    var imagePickerVC: UIImagePickerController!
    
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
            if let urlString = localUser.avatar?.url,
               let url = URL(string: urlString),
               let imageData = try? Data(contentsOf: url) {
                avatarImageView.image = UIImage(data: imageData)
                avatarNameLabel.isHidden = true
            } else {
                avatarImageView.isHidden = true
                avatarNameLabel.isHidden = false
                avatarNameLabel.text = "\(localUser.firstName?.first ?? Character(""))" + "\(localUser.lastName?.first ?? Character(""))"
                avatarNameLabel.layer.cornerRadius = avatarNameLabel.frame.height / 2
            }
        }
    }
    
    // MARK: Actions
    @IBAction func selectCameraOrGallery(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose option", message: "", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.checkCameraPermission()
        }
        alert.addAction(cameraAction)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.checkGalleryPermission()
        }
        alert.addAction(galleryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func checkCameraPermission() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authorised in
                guard let self = self else { return }
                if authorised {
                    DispatchQueue.main.async {
                        self.callCamera()
                    }
                }
            }
        case .restricted:
            print("User don't allow")
        case .denied:
            print("Denied status called")
            presentCameraSettings()
        case .authorized:
            callCamera()
        @unknown default:
            print("Error Occurred")
        }
    }
    
    func checkGalleryPermission() {
        PHPhotoLibrary.shared().register(self)
        let status = PHPhotoLibrary.authorizationStatus()
        showUI(for: status)
    }
    
    @IBAction func onClickUpdateProfile(_ sender: UIButton) {
        performUpdateProfile()
    }
    
    func removeAvatar() {
        localUser?.avatar = nil
    }
    
    func performUpdateProfile() {
        if !(emailField.text?.isValidEmail() ?? false) {
            errorLabel.text = "Please enter a valid email"
            return
        }
        
        setFormState(isEnabled: false)
        updateProfileButton.setTitle("Updating Profile", for: UIControl.State.disabled)
        
        if let user = localUser {
            APIClient.updateProfile(user: user) { updatedProfileResponse in
                
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
    
    func showUI(for status: PHAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorized:
                self.showFullAccessUI()
                
            case .limited:
                self.showLimitedAccessUI()
                
            case .restricted:
                self.showRestrictedAccessUI()
                
            case .denied:
                self.showAccessDeniedUI()
                
            case .notDetermined:
                self.showAccessNotDetermined()
                
            @unknown default:
                break
            }
        }
    }
    
    func showFullAccessUI() {
        imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true)
    }
    
    func showAccessNotDetermined() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch status {
                case .limited:
                    self.showLimitedAccessUI()
                case .authorized:
                    self.showFullAccessUI()
                case .denied:
                    break
                default:
                    break
                }
            }
        }
    }
    
    func showLimitedAccessUI() {
        let actionSheet = UIAlertController(title: "",
                                            message: "Select more photos or go to Settings to allow access to all photos.",
                                            preferredStyle: .actionSheet)
        
        let selectPhotosAction = UIAlertAction(title: "Select more photos",
                                               style: .default) { [unowned self] (_) in
            
            if #available(iOS 14, *) {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            } else {
                // Fallback on earlier versions
            }
            present(imagePickerVC, animated: true)
        }
        actionSheet.addAction(selectPhotosAction)
        
        let allowFullAccessAction = UIAlertAction(title: "Allow access to all photos",
                                                  style: .default) { [unowned self] (_) in
            gotoAppPrivacySettings()
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showRestrictedAccessUI() { }
    
    func showAccessDeniedUI() {
        let alert = UIAlertController(title: "Allow access to your photos",
                                      message: "This lets you share from your camera roll and enables other features for photos and videos. Go to your settings and tap \"Photos\".",
                                      preferredStyle: .alert)
        
        let notNowAction = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)
        alert.addAction(notNowAction)
        
        let openSettingsAction = UIAlertAction(
            title: "Open Settings",
            style: .default) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.gotoAppPrivacySettings()
                }
            }
        alert.addAction(openSettingsAction)
        
        present(alert, animated: true)
    }
    
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            assertionFailure("Not able to open App privacy settings")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage, let imageURL = info[.imageURL] as? URL {
                self.avatarNameLabel.isHidden = true
                self.avatarImageView.isHidden = false
                self.avatarImageView.image = image
                self.showProgressView()
                self.uploadAvatar(fileURL: imageURL)
            }
        }
    }
    
    func uploadAvatar(fileURL: URL) {
        DashX.uploadExternalAsset(fileURL: fileURL, externalColumnId: "e8b7b42f-1f23-431c-b739-9de0fba3dadf") { response in
            DispatchQueue.main.async {
                self.hideProgressView()
                if let jsonDictionary = response.jsonValue as? [String: Any] {
                    do {
                        let json = try JSONSerialization.data(withJSONObject: jsonDictionary)
                        let externalAssetData = try JSONDecoder().decode(ExternalAssetResponse.self, from: json)
                        let avatarAsset = AssetData(status: externalAssetData.status, url: externalAssetData.data?.assetData?.url)
                        self.localUser?.avatar = avatarAsset
                        // Enable Update profile after avatar is uploaded
                        self.updateProfileButton.isEnabled = true
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

// Camera
extension UpdateProfileViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) { }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera Access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:]) { [weak self] _ in
                    if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                        self?.callCamera()
                    }
                }
            }
        }))
        present(alertController, animated: true)
    }
    
    func callCamera() {
        imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .camera
        present(imagePickerVC, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

