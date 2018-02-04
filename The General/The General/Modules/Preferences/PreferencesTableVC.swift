//
//  PreferencesTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PreferencesTableVC: UITableViewController, OverlayNavigatable {

    private var sections: [PreferencesConfig] = []
    var communicationCells: [CommunicationRowConfig] = []
    var generalCells: [GeneralRowConfig] = []
    
    private enum SegueMap: String {
        case pushNotifications = "pushNotificationSegue"
        case email = "emailSegue"
        case textOrCall = "textSegue"
        case appPref = "appPrefSegue"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseNavigationController?.showMenuButton()
        tableView.tableFooterView = UIView()
        registerNibs()
        
        // tutorial overlay
        showHelpCenterOverlayIfNecessary()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPreferences()
    }
    
    
    // MARK: - Private Helpers
    private func registerNibs() {
        tableView.register(TableHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableHeaderView.identifier)
    }
    
   private func fetchPreferences() {
        LoadingView.show()
        ApplicationContext.shared.preferencesManager.fetchPreferences { (_) in
            ApplicationContext.shared.phoneOptionsManager.fetchPhones(completion: { [weak self] (innerClosure) in
                guard let sSelf = self else { return }
                LoadingView.hide()
                if let _ = try? innerClosure() {
                    sSelf.updateCells()
                }
            })
        }
    
    }
    
    private func updateCells() {
        sections = [
            .communications,
            .general
        ]
        
        communicationCells = [
            .pushNotifications,
            .email,
        ]
        
        if let _ = ApplicationContext.shared.phoneOptionsManager.phonesInfo {
            communicationCells += [
                .text,
                .autoCall
            ]
        }
        
        generalCells = [ .appPreferences ]
        self.tableView.reloadData()
    }

    
    // MARK: - Button Actions
    @IBAction func openSupport(_ sender: UIBarButtonItem) {
        ApplicationContext.shared.navigator.replace("pgac://support", context: nil, wrap: BaseNavigationController.self)
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        ApplicationContext.shared.navigator.replace("pgac://dashboard", context: nil, wrap: BaseNavigationController.self)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionIdentifier = sections[section]
        switch sectionIdentifier {
        case .communications: return communicationCells.count
        case .general: return generalCells.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrefTableViewCell", for: indexPath) as? PrefTableViewCell else { return UITableViewCell() }

        let sectionIdentifier = sections[indexPath.section]
        switch sectionIdentifier {
        case .communications:
            let row = indexPath.row
            let rowIdentifier = communicationCells[row]
            
            switch rowIdentifier {
            case .pushNotifications:
                cell.titleLabel.text = NSLocalizedString("preferences.titles.pushnotification", comment: "")
                if let notification = ApplicationContext.shared.preferencesManager.preferenceInfo?.pushNotifications?.filter({ $0.name == "global" }).first {
                    cell.valueLabel.text = notification.enabled ? NSLocalizedString("preferences.on", comment: "") : NSLocalizedString("preferences.off", comment: "")
                }
            case .email:
                cell.titleLabel.text = NSLocalizedString("preferences.titles.email", comment: "")
                if let notification = ApplicationContext.shared.preferencesManager.preferenceInfo?.email?.filter({ $0.name == "global" }).first {
                    cell.valueLabel.text = notification.enabled ? NSLocalizedString("preferences.on", comment: "") : NSLocalizedString("preferences.off", comment: "")
                }
            case .text:
                cell.titleLabel.text = NSLocalizedString("preferences.titles.textmessage", comment: "")
                if let phones = ApplicationContext.shared.phoneOptionsManager.phonesInfo?.phoneOpts {
                    let filtered = phones.filter({ $0.preferenceOriginal == .both || $0.preferenceOriginal == .text })
                    cell.valueLabel.text = filtered.count > 0 ? NSLocalizedString("preferences.on", comment: "") : NSLocalizedString("preferences.off", comment: "")
                }
                
            case .autoCall:
                cell.titleLabel.text = NSLocalizedString("preferences.titles.automatedcall", comment: "")
                if let phones = ApplicationContext.shared.phoneOptionsManager.phonesInfo?.phoneOpts {
                    let filtered = phones.filter({ $0.preferenceOriginal == .both || $0.preferenceOriginal == .call })
                    cell.valueLabel.text = filtered.count > 0 ? NSLocalizedString("preferences.on", comment: "") : NSLocalizedString("preferences.off", comment: "")
                }

            }
        case .general:
            let rowIdentifier = generalCells[indexPath.row]
            switch rowIdentifier {
            case .appPreferences:
                cell.titleLabel.text = NSLocalizedString("preferences.titles.apppreferences", comment: "")
                if let notification = ApplicationContext.shared.preferencesManager.preferenceInfo?.appPreferences?.filter({ $0.name == "allowInsuranceVerificationWhenLogout" }).first {
                    cell.valueLabel.text = notification.enabled ? NSLocalizedString("preferences.on", comment: "") : ""
                }else{
                    cell.valueLabel.text = NSLocalizedString("preferences.off", comment: "")
                }
            }
        }

        return cell
    }
        
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.identifier) as! TableHeaderView
        let sectionIdentifier = sections[section]
        switch sectionIdentifier {
        case .communications:
            cell.headerLabel?.text = NSLocalizedString("preferences.sectiontitle.communication", comment: "")
        case .general:
            cell.headerLabel?.text = NSLocalizedString("preferences.sectiontitle.generalapp", comment: "")
        }
        cell.leftXConstraint?.constant = 12
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionIdentifier = sections[indexPath.section]

        switch sectionIdentifier {
        case .communications:
            let row = indexPath.row
            let rowIdentifier = communicationCells[row]
            
            switch rowIdentifier {
            case .pushNotifications: self.performSegue(withIdentifier: SegueMap.pushNotifications.rawValue, sender: ApplicationContext.shared.preferencesManager.preferenceInfo?.pushNotifications)
            case .email: self.performSegue(withIdentifier: SegueMap.email.rawValue, sender: ApplicationContext.shared.preferencesManager.preferenceInfo?.email)
            case .text: self.performSegue(withIdentifier: SegueMap.textOrCall.rawValue, sender: VCMode.allowsTexts)
            case .autoCall: self.performSegue(withIdentifier: SegueMap.textOrCall.rawValue, sender: VCMode.allowsCalls)
            }
        
        case .general:
            self.performSegue(withIdentifier: SegueMap.appPref.rawValue, sender: ApplicationContext.shared.preferencesManager.preferenceInfo?.appPreferences)
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let seguer = segue.identifier, seguer == SegueMap.textOrCall.rawValue {
            if let cnt = segue.destination as? TextPreferencesTableVC {
                cnt.currentConfig = sender as! VCMode
            }
        }
        
        if let seguer = segue.identifier, seguer == SegueMap.email.rawValue {
            if let cnt = segue.destination as? EmailPreferencesTableVC {
                cnt.emailPreferences = sender as? [Notifications]
            }
        }

        if let seguer = segue.identifier, seguer == SegueMap.appPref.rawValue {
            if let cnt = segue.destination as? AppPreferencesTableVC {
                cnt.appPreferences = sender as? [Notifications]
            }
        }

        if let seguer = segue.identifier, seguer == SegueMap.pushNotifications.rawValue {
            if let cnt = segue.destination as? PushNotificationPreferenceTableVC {
                cnt.pushPreferences = sender as? [Notifications]
            }
        }

    }

}


extension PreferencesTableVC {

    enum PreferencesConfig {
        case communications
        case general
    }
    
    enum CommunicationRowConfig {
        case pushNotifications
        case email
        case text
        case autoCall
    }
        
    enum GeneralRowConfig {
        case appPreferences
    }

}
