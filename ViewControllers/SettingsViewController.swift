//
//  SettingsViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 22/07/22.
//

import UIKit
import DashX

class SettingsViewController: UIViewController {
    static let identifier = "SettingsViewController"
    
    // MARK: - Outlets
    @IBOutlet weak var someOneCreatesAPostSwitch: UISwitch!
    @IBOutlet weak var someOneBookmarksYourPostSwitch: UISwitch!
    private var rightBarButton: UIBarButtonItem!
    
    var preferenceData: PreferenceDataResponse!
    
    private var newBookmarkNotificationEnabled: Bool = false {
        didSet {
            if someOneBookmarksYourPostSwitch != nil {
                someOneBookmarksYourPostSwitch.isOn = newBookmarkNotificationEnabled
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
        
        setUpRightBarButton()
        setUpToggleListeners()
        self.navigationItem.title = "Preferences"
    }
    
    // MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchStoredPreferences()
    }
    
    // MARK: - TraitCollectionDidChange
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
    }
    
    func setUpRightBarButton() {
        rightBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        rightBarButton.tintColor = .systemBlue
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setUpToggleListeners() {
        someOneCreatesAPostSwitch.addTarget(self, action: #selector(onSwitchValueChanged), for: .valueChanged)
        someOneBookmarksYourPostSwitch.addTarget(self, action: #selector(onSwitchValueChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc
    func rightBarButtonTapped() {
        saveStoredPreferences()
    }
    
    @objc
    func onSwitchValueChanged(_ view: UISwitch) { }
    
    func fetchStoredPreferences() {
        isPreferencesLoading = true
        DashX.fetchStoredPreferences { response in
            DispatchQueue.main.async {
                if let jsonDictionary = response.jsonValue as? [String: Any] {
                    do {
                        let json = try JSONSerialization.data(withJSONObject: jsonDictionary)
                        let preferenceData = try JSONDecoder().decode(PreferenceDataResponse.self, from: json)
                        self.preferenceData = preferenceData
                        self.newBookmarkNotificationEnabled = preferenceData.newBookmarkNotificationEnabled
                        self.newPostNotificationEnabled = preferenceData.newPostNotificationEnabled
                    } catch {
                        self.showError(with: error.localizedDescription)
                    }
                } else {
                    self.showError(with: "Stored preferences response is empty.")
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
        preferenceData.newPost.enabled = someOneCreatesAPostSwitch.isOn
        preferenceData.newBookmark.enabled = someOneBookmarksYourPostSwitch.isOn
        if let data = try? JSONEncoder().encode(preferenceData), let dictionary = try? JSONSerialization.jsonObject(with: data) as? NSDictionary {
            DashX.saveStoredPreferences(preferenceData: dictionary) { response in
                DispatchQueue.main.async {
                    print(response.jsonValue)
                    if let jsonDictionary = response.jsonValue as? [String: Any] {
                        if let success = jsonDictionary["success"] as? Bool, success {
                            self.newBookmarkNotificationEnabled = self.someOneBookmarksYourPostSwitch.isOn
                            self.newPostNotificationEnabled = self.someOneCreatesAPostSwitch.isOn
                            self.showSuccess(with: "Preferences saved.")
                        } else {
                            self.showError(with: "Save stored preferences response is empty.")
                        }
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
    }
}
