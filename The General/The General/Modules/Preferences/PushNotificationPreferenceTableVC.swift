//
//  PushNotificationPreferenceTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/19/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PushNotificationPreferenceTableVC: UITableViewController {

    var pushPreferences: [Notifications]? {
        didSet {
            updateCells()
        }
    }
    
    private var sections: [PushNotificationPreferenceConfig] = []
    private var globalRows: [GlobalPushTypeConfig] = []
    private var pushTypeRows: [PushTypeConfig] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        registerNibs()
    }
    
    
    // MARK: Navigation bar button actions
    @IBAction func backTouched(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openSupportTouched(_ sender: UIBarButtonItem) {
        ApplicationContext.shared.navigator.replace("pgac://support", context: nil, wrap: BaseNavigationController.self)
    }
    
    
    // MARK: Private Helpers
    func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func registerNibs() {
        tableView.register(TableHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableHeaderView.identifier)
    }
    
    private func updateCells() {
        
        sections = [ .global ]
        globalRows = [ .globalPush ]
        if let preferences = pushPreferences {
            if let notification = preferences.filter({ $0.name == "global" }).first {
                if notification.enabled {
                    sections += [ .communication ]
                    pushTypeRows = [
                        .claimUpdates,
                        .policyAlerts,
                        .paymentReminders,
                        .quoteReminders
                    ]
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    /// Update Push Notification preferences and fetches latest
    ///
    /// - Parameters:
    ///   - preference: the preference that needs to be updated
    ///   - newValue: updated Bool value
    private func updatePushNotification(with preference: String, newValue: Bool) {
        
        let preferenceInfo: [String: Any] = [
            "preferenceName": "pushNotifications",
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
                sSelf.pushPreferences = ApplicationContext.shared.preferencesManager.preferenceInfo?.pushNotifications
                LoadingView.hide()
                AnalyticsManager.track(event: .communicationPreferencesChangeDidComplete)
            })
        })
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionIdentifier = sections[section]
        switch sectionIdentifier {
        case .global: return globalRows.count
        case .communication: return pushTypeRows.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let pushPreferences = pushPreferences else { return UITableViewCell() }
        let sectionIdentifier = sections[indexPath.section]

        switch sectionIdentifier {
        case .global:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as? SwitchTableViewCell {
                let key = "global"
                cell.title.text = NSLocalizedString("preferences.titles.pushnotify.emailallow", comment: "")
                if let notification = pushPreferences.filter({ $0.name == key }).first {
                    cell.switchYesorNo.value = notification.enabled
                }
                cell.valueChange = { [weak self] newVal in
                    self?.updatePushNotification(with: key, newValue: newVal)
                }
                return cell
            }

        case .communication:
            
            let row = indexPath.row
            let rowIdentifier = pushTypeRows[row]
            let key = rowIdentifier.keyValue
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchOnOffTableViewCell", for: indexPath) as? SwitchOnOffTableViewCell {
                
                switch rowIdentifier {
                case .claimUpdates:
                    cell.title.text = NSLocalizedString("preferences.titles.pushnotify.accountreminders", comment: "")
                case .policyAlerts:
                    cell.title.text = NSLocalizedString("preferences.titles.pushnotify.claimupdates", comment: "")
                case .paymentReminders:
                    cell.title.text = NSLocalizedString("preferences.titles.pushnotify.paperless", comment: "")
                case .quoteReminders:
                    cell.title.text = NSLocalizedString("preferences.titles.pushnotify.quotes", comment: "")
                }
                
                if let notification = pushPreferences.filter({ $0.name == key }).first {
                    cell.switchOnOff.value = notification.enabled
                }
                cell.valueChange = { [weak self] newVal in
                    self?.updatePushNotification(with: key, newValue: newVal)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionIdentifier = sections[section]
        
        switch sectionIdentifier {
        case .global:
            return nil
        case .communication:
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.identifier) as! TableHeaderView
            cell.headerLabel?.text = NSLocalizedString("preferences.sectiontitle.email.communication", comment: "")
            cell.leftXConstraint?.constant = 12
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionIdentifier = sections[section]
        switch sectionIdentifier {
        case .global: return 0
        case .communication: return UITableViewAutomaticDimension
        }
    }
}

extension PushNotificationPreferenceTableVC {
    
    enum PushNotificationPreferenceConfig {
        case global
        case communication
    }
    
    enum GlobalPushTypeConfig {
        case globalPush
        
        var keyValue: String {
            switch self {
            case .globalPush: return "global"
            }
        }
    }
    
    enum PushTypeConfig {
        case claimUpdates
        case policyAlerts
        case paymentReminders
        case quoteReminders
        
        var keyValue: String {
            switch self {
            case .claimUpdates: return "claimUpdates"
            case .policyAlerts: return "policyAlerts"
            case .paymentReminders: return "paymentReminders"
            case .quoteReminders: return "quoteReminders"
            }
        }

    }
}
