//
//  AppPreferencesTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/19/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AppPreferencesTableVC: UITableViewController {

    var oauthController: OAuthController!
    var appPreferences: [Notifications]? {
        didSet {
            reload()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.oauthController = OAuthController(parentViewController: self)
        tableView.tableFooterView = UIView()
        registerNibs()
        
        AnalyticsManager.track(event: .appPreferencesWasVisited)
    }

    @IBAction func backTouched(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openSupportTouched(_ sender: UIBarButtonItem) {
        ApplicationContext.shared.navigator.replace("pgac://support", context: nil, wrap: BaseNavigationController.self)
    }
    
    
    // MARK: - Private Helpers
    private func registerNibs() {
        tableView.register(TableHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableHeaderView.identifier)
    }
    
    private func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /// Update App preferences
    ///
    /// - Parameters:
    ///   - preference: the app preference value that needs to be updated
    ///   - newValue: updated Bool value
    private func updateAppPreference(with preference: String, newValue: Bool) {
        let preferenceInfo: [String: Any] = [
            "preferenceName": "appPreferences",
            "preferences": [
                "name": preference,
                "enabled": newValue
            ]
        ]
        AnalyticsManager.track(event: .communicationPreferencesChangeWasInitiated)
        LoadingView.show()
        ApplicationContext.shared.preferencesManager.updatePreferences(with: preferenceInfo, completion: { (_) in
            ApplicationContext.shared.preferencesManager.fetchPreferences(completion: { [weak self] (_) in
                guard let sSelf = self else { return }
                sSelf.appPreferences = ApplicationContext.shared.preferencesManager.preferenceInfo?.appPreferences
                LoadingView.hide()
                AnalyticsManager.track(event: .communicationPreferencesChangeDidComplete)
            })
        })
    }


    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return AppPreferencesConfig.sectionCount()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppPreferencesConfig.rowCount(at: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let appPreferences = appPreferences else { return UITableViewCell() }
        let config = AppPreferencesConfig.row(at: indexPath.section, row: indexPath.row)
        let key = config.keyValue
        
        switch config {
        case .electronicInsurance:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as? SwitchTableViewCell {
                cell.title.text = AppPreferencesConfig.title(with: config)
                if let notification = appPreferences.filter({ $0.name == key }).first {
                    cell.switchYesorNo.value = notification.enabled
                }
                cell.valueChange = { [weak self] (value) in
                    if value {
                        AnalyticsManager.track(event: .appPreferenceSetAllowIDCardAccessWhileLoggedOut)
                    }
                    self?.updateAppPreference(with: "allowInsuranceVerificationWhenLogout", newValue: value)
                    self?.reload()
                }
                return cell
            }
        case .enableTouchId:
            if SettingsManager.biometryEnabled {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchOnOffTableViewCell", for: indexPath) as? SwitchOnOffTableViewCell {
                    cell.title.text = AppPreferencesConfig.title(with: config)
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TextDescriptionTableViewCell", for: indexPath) as? TextDescriptionTableViewCell {
                    cell.lblTitle.text = AppPreferencesConfig.title(with: config)
                    cell.lblDescription.text = NSLocalizedString("preferences.app.touchid.notsetup", comment: "")
                    return cell
                }
            }
        case .fblogin:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchOnOffTableViewCell", for: indexPath) as? SwitchOnOffTableViewCell {
                cell.title.text = AppPreferencesConfig.title(with: config)
                if let notification = appPreferences.filter({ $0.name == key }).first {
                    cell.switchOnOff.value = notification.enabled
                }
                cell.valueChange = { [weak self] newVal in
                    if newVal {
                        self?.oauthController.facebookSignIn() { success in
                            PreferencesManager.loggedInWithFb = success
                            self?.updateAppPreference(with: "facebookLogin", newValue: newVal)
                        }
                    }
                    self?.reload()
                }
                return cell
            }
        case .googlelogin:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchOnOffTableViewCell", for: indexPath) as? SwitchOnOffTableViewCell {
                cell.title.text = AppPreferencesConfig.title(with: config)
                if let notification = appPreferences.filter({ $0.name == key }).first {
                    cell.switchOnOff.value = notification.enabled
                }
                cell.valueChange = { [weak self] newVal in
                    if newVal {
                        self?.oauthController.googleSignIn() { success in
                            PreferencesManager.loggedInWithGoogle = success
                            self?.updateAppPreference(with: "googleLogin", newValue: newVal)
                        }
                    }
                    self?.reload()
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = AppPreferencesConfig.title(at: section) else { return nil }
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.identifier) as! TableHeaderView
        cell.headerLabel?.text = title
        cell.leftXConstraint?.constant = 12
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let _ = AppPreferencesConfig.title(at: section) {
            return UITableViewAutomaticDimension
        }
        return 0
    }

}

fileprivate enum AppPreferencesConfig {
    case electronicInsurance
    case enableTouchId
    case fblogin
    case googlelogin
    
    var keyValue: String {
        switch self {
        case .electronicInsurance: return "allowInsuranceVerificationWhenLogout"
        case .enableTouchId: return "TouchIdLogin"
        case .fblogin: return "facebookLogin"
        case .googlelogin: return "googleLogin"
        }
    }
    
    static func sectionCount() -> Int {
        return 2
    }
    
    static func rowCount(at section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        default:
            return 0
        }
    }
    
    static func row(at section: Int, row: Int) -> AppPreferencesConfig {
        switch (section, row) {
        case (0, 0): return electronicInsurance
        case (1, 0): return enableTouchId
        case (1, 1): return fblogin
        case (1, 2): return googlelogin
        default:
            return electronicInsurance
        }
    }
    
    static func title(with config: AppPreferencesConfig) -> String {
        switch config {
        case .electronicInsurance: return NSLocalizedString("preferences.app.electronicverification", comment: "")
        case .enableTouchId: return NSLocalizedString("preferences.app.touchid", comment: "")
        case .fblogin: return NSLocalizedString("preferences.app.fb", comment: "")
        case .googlelogin: return NSLocalizedString("preferences.app.google", comment: "")
        }
    }

    static func title(at section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return NSLocalizedString("preferences.app.login", comment: "")
        default: break
        }
        return nil
    }
}
