//
//  SettingsViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 22/07/22.
//

import UIKit

class SettingsViewController: UIViewController {
    static let identifier = "SettingsViewController"
    
    // MARK: - Outlets
    @IBOutlet weak var someOneCreatesAPostSwitch: UISwitch!
    @IBOutlet weak var someOneBookmarksYourPostSwitch: UISwitch!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.titleLabel?.textColor = UIColor(named: "primaryColor")
            cancelButton.layer.cornerRadius = 6
            cancelButton.layer.borderColor = UIColor(named: "primaryColor")?.cgColor
            cancelButton.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.backgroundColor = UIColor(named: "primaryColor")
            saveButton.setTitleColor(UIColor.white, for: .normal)
            saveButton.layer.cornerRadius = 6
        }
    }
    
    private var newBookMarkNotificationEnabled: Bool = false {
        didSet {
            if someOneBookmarksYourPostSwitch != nil {
                someOneBookmarksYourPostSwitch.isOn = newBookMarkNotificationEnabled
            }
        }
    }
    private var newPostNotificationEnabled: Bool = false {
        didSet {
            if someOneCreatesAPostSwitch != nil {
                someOneCreatesAPostSwitch.isOn = newPostNotificationEnabled
            }
        }
    }
    private var isPreferencesLoading: Bool = false {
        didSet {
            if self.isPreferencesLoading {
                self.showProgressView()
            } else {
                self.hideProgressView()
            }
        }
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchStoredPreferences()
        setToggleListeners()
        setButtonsState(isHidden: true)
        self.navigationItem.title = "Preferences"
    }
    
    // MARK: - TraitCollectionDidChange
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
    }
    
    // MARK: - Actions
    @IBAction func onClickCancel(_ sender: UIButton) {
        resetToggles()
        setButtonsState(isHidden: true)
    }
    
    @IBAction func onClickSave(_ sender: UIButton) {
        saveStoredPreferences()
    }
    
    func setToggleListeners() {
        someOneCreatesAPostSwitch.addTarget(self, action: #selector(onSwitchValueChanged), for: .valueChanged)
        someOneBookmarksYourPostSwitch.addTarget(self, action: #selector(onSwitchValueChanged), for: .valueChanged)
    }
    
    var valueUpdated: Bool {
        (someOneCreatesAPostSwitch.isOn != newPostNotificationEnabled) || (someOneBookmarksYourPostSwitch.isOn != newBookMarkNotificationEnabled)
    }
    
    @objc
    func onSwitchValueChanged(_ view: UISwitch) {
        switch view {
        case someOneCreatesAPostSwitch:
            setButtonsState(isHidden: !valueUpdated)
            break
        case someOneBookmarksYourPostSwitch:
            setButtonsState(isHidden: !valueUpdated)
            break
        default:
            break
        }
    }
    
    func setButtonsState(isHidden: Bool) {
        buttonsStackView.isHidden = isHidden
    }
    
    func resetToggles() {
        someOneCreatesAPostSwitch.isOn = newPostNotificationEnabled
        someOneBookmarksYourPostSwitch.isOn = newBookMarkNotificationEnabled
    }
    
    func fetchStoredPreferences() {
        isPreferencesLoading = true
        DashXUtils.client1.fetchStoredPreferences { response in
            DispatchQueue.main.async {
                if let jsonDictionary = response.jsonValue as? [String: Any] {
                    do {
                        let json = try JSONSerialization.data(withJSONObject: jsonDictionary)
                        let preferenceData = try JSONDecoder().decode(PreferenceDataResponse.self, from: json)
                        self.newBookMarkNotificationEnabled = preferenceData.newBookMarkNotificationEnabled
                        self.newPostNotificationEnabled = preferenceData.newPostNotificationEnabled
                    } catch {
                        self.showError(with: error.localizedDescription)
                    }
                } else {
                    self.showError(with: "Stored preferences response is empty")
                }
                self.isPreferencesLoading = false
            }
        } failureCallback: { error in
            DispatchQueue.main.async {
                self.showError(with: error.localizedDescription)
                self.isPreferencesLoading = false
            }
        }
    }
    
    func saveStoredPreferences() {
        isPreferencesLoading = true
        let preferenceData: NSDictionary = [
            "new-bookmark":
                [
                    "enabled": someOneBookmarksYourPostSwitch.isOn
                ],
            "new-post":
                [
                    "enabled": someOneCreatesAPostSwitch.isOn
                ]
        ]
        DashXUtils.client1.saveStoredPreferences(preferenceData: preferenceData) { response in
            DispatchQueue.main.async {
                print(response.jsonValue)
                if let jsonDictionary = response.jsonValue as? [String: Any] {
                    if let success = jsonDictionary["success"] as? Bool, success {
                        self.newBookMarkNotificationEnabled = self.someOneBookmarksYourPostSwitch.isOn
                        self.newPostNotificationEnabled = self.someOneCreatesAPostSwitch.isOn
                        // Show success
                    } else {
                        self.showError(with: "Save stored preferences response is empty")
                    }
                }
                self.setButtonsState(isHidden: true)
                self.isPreferencesLoading = false
            }
        } failureCallback: { error in
            DispatchQueue.main.async {
                self.showError(with: error.localizedDescription)
                self.setButtonsState(isHidden: true)
                self.isPreferencesLoading = false
            }
        }
    }
}
