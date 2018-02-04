//
//  TextPreferencesTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/19/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import SafariServices

public enum VCMode {
    case allowsCalls
    case allowsTexts
}

class TextPreferencesTableVC: UITableViewController {

    public var currentConfig: VCMode = .allowsCalls
    private var rowCells: [TextPreferenceRows] = []
    private let privacyPolicyUrl = URL(string: "https://www.thegeneral.com/legal/privacy-policy/")!
    private let termsAndConditionsUrl = URL(string: "https://www.thegeneral.com/legal/terms-and-conditions/")!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        setNavigationTitle()
        updateCells()
    }
    
    
    // MARK: Navigation bar button actions
    @IBAction func backTouched(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openSupportTouched(_ sender: UIBarButtonItem) {
        ApplicationContext.shared.navigator.replace("pgac://support", context: nil, wrap: BaseNavigationController.self)
    }
    
    
    // MARK: Private Helpers
    private func setNavigationTitle() {
        switch currentConfig {
        case .allowsTexts:
            self.navigationItem.title = NSLocalizedString("preferences.titles.textmessage", comment: "")
        case .allowsCalls:
            self.navigationItem.title = NSLocalizedString("preferences.titles.automatedcall", comment: "")
        }
    }
    
    private func updateCells() {
        rowCells = [ .text ]
        if let phones = ApplicationContext.shared.phoneOptionsManager.phonesInfo?.phoneOpts {
            if let _ = phones.filter({ $0.isPrimary }).first {
                rowCells += [ .primaryPhone ]
            }
            if let _ = phones.filter({ !$0.isPrimary }).first {
                rowCells += [ .secondaryPhone ]
            }
        }
        tableView.reloadData()
    }
    
    /// Update text and automated call preferences and fetch latest
    ///
    /// - Parameters:
    ///   - preference: the preference that needs to be updated
    ///   - newValue: updated Bool value
    private func updatePreferences(with preference: Bool, options: PhoneOptionsResponse) {
        
        var newPreference: PhoneStatusType = .none
        /// Based on the current vc config, i.e. calls or text, and the current preference of the phone number
        /// determine the new preference.
        switch options.preferenceOriginal {
        case .none:
            newPreference = currentConfig == .allowsCalls ? .call : .text
        case .call:
            newPreference = currentConfig == .allowsCalls ? .none : .both
        case .text:
            newPreference = currentConfig == .allowsCalls ? .both : .none
        case .both:
            newPreference = currentConfig == .allowsCalls ? .text : .call
        }
        let updatePhone = PhoneOptionsRequest(fName: options.fName,
                                              lName: options.lName,
                                              middleInitial: options.middleInitial,
                                              driverNo: options.driverNo,
                                              phoneAreaOriginal: options.phoneAreaOriginal,
                                              phoneNumberOriginal: options.phoneNumberOriginal,
                                              phoneArea: options.phoneAreaOriginal,
                                              phoneNumber: options.phoneNumberOriginal,
                                              primaryFlag: options.primaryFlag,
                                              preferenceOriginal: options.preferenceOriginal.rawValue,
                                              preferenceNew: newPreference.rawValue)
        
        AnalyticsManager.track(event: .communicationPreferencesChangeWasInitiated)
        
        LoadingView.show()
        ApplicationContext.shared.phoneOptionsManager.updatePhones(with: [updatePhone]) { (_) in
            ApplicationContext.shared.phoneOptionsManager.fetchPhones(completion: { [weak self] (_) in
                guard let sSelf = self else { return }
                LoadingView.hide()
                sSelf.updateCells()
                AnalyticsManager.track(event: .communicationPreferencesChangeDidComplete)
            })
        }
    }
    
    private func open(url: URL) {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.delegate = self
            rootViewController.present(safariViewController, animated: true, completion: nil)
        }
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowCells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let phones = ApplicationContext.shared.phoneOptionsManager.phonesInfo?.phoneOpts else { return UITableViewCell() }

        let row = rowCells[indexPath.row]
        switch row {
        case .text:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewTableViewCell", for: indexPath) as? TextViewTableViewCell {
                cell.fill(with: currentConfig)
                cell.delegate = self
                return cell
            }

        case .primaryPhone:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchOnOffTableViewCell", for: indexPath) as? SwitchOnOffTableViewCell {
                if let primary = phones.filter({ $0.isPrimary }).first {
                    cell.title.text = String(format: "%@ %@", NSLocalizedString("preferences.textpreference.primaryphone", comment: ""), primary.formattedOriginalPhone)
                    if currentConfig == .allowsTexts {
                        cell.switchOnOff.value = primary.preferenceOriginal == .text || primary.preferenceOriginal == .both
                    }
                    if currentConfig == .allowsCalls {
                        cell.switchOnOff.value = primary.preferenceOriginal == .call || primary.preferenceOriginal == .both
                    }
                    cell.valueChange = { [weak self] newVal in
                        self?.updatePreferences(with: newVal, options: primary)
                    }
                }
                return cell
            }
        case .secondaryPhone:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchOnOffTableViewCell", for: indexPath) as? SwitchOnOffTableViewCell {
                if let secondary = phones.filter({ !$0.isPrimary }).first {
                    cell.title.text = String(format: "%@ %@", NSLocalizedString("preferences.textpreference.altphone", comment: ""), secondary.formattedOriginalPhone)
                    if currentConfig == .allowsTexts {
                        cell.switchOnOff.value = secondary.preferenceOriginal == .text || secondary.preferenceOriginal == .both
                    }
                    if currentConfig == .allowsCalls {
                        cell.switchOnOff.value = secondary.preferenceOriginal == .call || secondary.preferenceOriginal == .both
                    }
                    cell.valueChange = { [weak self] newVal in
                        self?.updatePreferences(with: newVal, options: secondary)
                    }

                }
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

extension TextPreferencesTableVC: AttributedLinks {
    func openTerms() {
        open(url: termsAndConditionsUrl)
    }
    
    func openPrivacy() {
        open(url: privacyPolicyUrl)
    }
}

extension TextPreferencesTableVC: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            controller.dismiss(animated: true, completion: {
                // TODO: Show alert
            })
        }
    }
}

extension TextPreferencesTableVC {
    enum TextPreferenceRows {
        case text
        case primaryPhone
        case secondaryPhone
    }
}
