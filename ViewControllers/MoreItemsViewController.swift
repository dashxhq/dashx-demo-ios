//
//  MoreItemsViewController.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 01/07/22.
//
import UIKit
import DashX

typealias MoreScreenDataItem = (title: String, action: () -> Void)

class MoreItemsViewController: UIViewController {
    static let identifier = "MoreItemsViewController"
    @IBOutlet var tableView: UITableView!
    
    var screenItems: [MoreScreenDataItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenItems = [
            (title: "Billing", action: { return }),
            (title: "Profile", action: goToUpdateProfileScreen),
            (title: "Settings", action: { return }),
            (title: "Logout", action: performLogout)
        ]
        
        // Setup tableview
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
    }
    
    func goToUpdateProfileScreen() {
        let updateProfileVC = UIViewController.instance(of: UpdateProfileViewController.identifier)
        self.navigationController?.pushViewController(updateProfileVC, animated: true)
    }
    
    func performLogout() {
        // Induce artificial "processing" gap instead of snappy logout
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            // Clear local storage keys
            LocalStorage.instance.clearAll()
            
            let loginVC = UIViewController.instance(of: LoginViewController.identifier)
            let navVC = UINavigationController(rootViewController: loginVC)
            self.view.window?.rootViewController = navVC
        }
    }
}

extension MoreItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let screenItemIndex = indexPath.row
        let onClickAction = screenItems[screenItemIndex].action
        
        onClickAction()
    }
}

extension MoreItemsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screenItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let screenItemIndex = indexPath.row
        let cellTitle = screenItems[screenItemIndex].title
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreScreenTableViewCell",
                                                 for: indexPath) as! MoreScreenTableViewCell
        
        cell.titleLabel.text = cellTitle
        
        return cell
    }
}
