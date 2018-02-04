//
//  EmailPreferencesTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class EmailPreferencesTableVC: UITableViewController {

    var emailPreferences: [Notifications]? {
        didSet {
            updateCells()
        }
    }
    
    private var sections: [EmailPreferenceConfig] = []
    private var globalRows: [GlobalEmailConfig] = []
    private var emailTypeRows: [EmailTypeConfig] = []
    
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
        globalRows = [ .globalEmail ]
        if let preferences = emailPreferences {
            if let notification = preferences.filter({ $0.name == "global" }).first {
                if notification.enabled {
                    sections += [ .communication ]
                    emailTypeRows = [
                        .accountReminders,
                        .claimUpdates,
                        .paperless,
                        .news,
                        .surveys
                    ]
                }
            }
        }
        self.tableView.reloadData()
    }
    
    /// Update Email preferences and fetches latest
    ///
    /// - Parameters:
    ///   - preference: the email preference that needs to be updated
    ///   - newValue: updated Bool value
    private func updateEmail(with preference: String, newValue: Bool) {
        let preferenceInfo: [String: Any] = [
            "preferenceName": "email",
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
                sSelf.emailPreferences = ApplicationContext.shared.preferencesManager.preferenceInfo?.email
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
        case .communication: return emailTypeRows.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let emailPreferences = emailPreferences else { return UITableViewCell() }
        
        let sectionIdentifier = sections[indexPath.section]
        
        switch sectionIdentifier {
        case .global:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as? SwitchTableViewCell {
                let key = "global"
                cell.title.text = NSLocalizedString("preferences.titles.email.emailallow", comment: "")
                if let notification = emailPreferences.filter({ $0.name == key }).first {
                    cell.switchYesorNo.value = notification.enabled
                }
                cell.valueChange = { [weak self] newVal in
                    self?.updateEmail(with: key, newValue: newVal)
                }
                return cell
            }
            
        case .communication:
            
            let row = indexPath.row
            let rowIdentifier = emailTypeRows[row]
            let key = rowIdentifier.keyValue
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchOnOffTableViewCell", for: indexPath) as? SwitchOnOffTableViewCell {

                switch rowIdentifier {
                case .accountReminders:
                    cell.title.text = NSLocalizedString("preferences.titles.email.accountreminders", comment: "")
                case .claimUpdates:
                    cell.title.text = NSLocalizedString("preferences.titles.email.claimupdates", comment: "")
                case .paperless:
                    cell.title.text = NSLocalizedString("preferences.titles.email.paperless", comment: "")
                case .news:
                    cell.title.text = NSLocalizedString("preferences.titles.email.newspromotions", comment: "")
                case .surveys:
                    cell.title.text = NSLocalizedString("preferences.titles.email.surveys", comment: "")
                }
                
                if let notification = emailPreferences.filter({ $0.name == key }).first {
                    cell.switchOnOff.value = notification.enabled
                }
                cell.valueChange = { [weak self] newVal in
                    self?.updateEmail(with: key, newValue: newVal)
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

extension EmailPreferencesTableVC {
    
    enum EmailPreferenceConfig {
        case global
        case communication
    }
    
    enum GlobalEmailConfig {
        case globalEmail
        
        var keyValue: String {
            switch self {
            case .globalEmail: return "global"
            }
        }
    }
    
    enum EmailTypeConfig {
        case accountReminders
        case claimUpdates
        case paperless
        case news
        case surveys

        var keyValue: String {
            switch self {
            case .accountReminders: return "accountReminders"
            case .claimUpdates: return "claimUpdates"
            case .paperless: return "paperlessBillingAndDocuments"
            case .news: return "newsAndPromotions"
            case .surveys: return "surveys"
            }
        }
        
    }
}
