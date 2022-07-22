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
    
    private var formUtils: FormUtils!
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchStoredPreferences()
        someOneCreatesAPostSwitch.addTarget(self, action: #selector(onSwitchValueChanged), for: .valueChanged)
        someOneBookmarksYourPostSwitch.addTarget(self, action: #selector(onSwitchValueChanged), for: .valueChanged)
        self.navigationItem.title = "Preferences"
        formUtils = FormUtils(fields: [someOneCreatesAPostSwitch, someOneBookmarksYourPostSwitch])
    }
    
    // MARK: - TraitCollectionDidChange
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
    }
    
    func setFormState(isEnabled: Bool) {
        formUtils.setFieldsStatus(isEnabled: isEnabled)
    }
    
    @objc
    func onSwitchValueChanged(_ view: UISwitch) {
        switch view {
        case someOneCreatesAPostSwitch:
            saveStoredPreferences()
            break
        case someOneBookmarksYourPostSwitch:
            saveStoredPreferences()
            break
        default:
            break
        }
    }
    
    func saveStoredPreferences() { }
    
    func fetchStoredPreferences() {
        DashXUtils.client1.fetchStoredPreferences { response in
            print(response.jsonValue)
        } failureCallback: { error in
            print(error)
        }
    }
}
