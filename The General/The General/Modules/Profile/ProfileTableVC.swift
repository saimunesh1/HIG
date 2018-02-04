//
//  ProfileTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/20/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ProfileTableVC: UITableViewController, OverlayNavigatable {

    struct SegueMap {
        static let contactEdit = "editProfileSegue"
        static let passwordEdit = "changePasswordSegue"
    }
    private var sections: [ProfileSectionConfig] = []
    private var contactRows: [ContactRowConfig] = []
    private var passwordRows: [PasswordRowConfig] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        baseNavigationController?.showMenuButton()
        
        setUpCells()

        // tutorial overlay
        showHelpCenterOverlayIfNecessary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getProfileData()
    }
    
    
    // MARK: - Button Actions
    @IBAction func openSupportTouched(_ sender: UIBarButtonItem) {
        UIApplication.shared.keyWindow?.rootViewController?.notYetImplemented()
    }
    
    
    // MARK: Private Helpers
    private func getProfileData() {
        LoadingView.show()
        let group = DispatchGroup()
        if let _ = SessionManager.policyNumber {
            
            // Get Email Info
            group.enter()
            ApplicationContext.shared.profileManager.getProfileDetails(completion: { (innerClosure) in
                _ = try? innerClosure()
                group.leave()
            })
            
            // Get Address Info
            group.enter()
            ApplicationContext.shared.profileManager.getAddressDetails(completion: { (innerClosure) in
                _ = try? innerClosure()
                group.leave()
            })
            
            // Get Phone Numbers
            group.enter()
            ApplicationContext.shared.phoneOptionsManager.fetchPhones(completion: { (innerClosure) in
                _ = try? innerClosure()
                group.leave()
            })
        }
        
        group.notify(queue: .main, work: DispatchWorkItem(block: { [weak self] in
            guard let sSelf = self else { return }
            LoadingView.hide()
            sSelf.updateCells()
        }))

    }
    
    private func setUpCells() {
        tableView.tableFooterView = UIView()
        tableView.register(ProfileSectionHeader.nib, forHeaderFooterViewReuseIdentifier: ProfileSectionHeader.identifier)
    }
        
    private func updateCells() {
        sections = [
            .contact,
            .password
        ]
        
        contactRows.removeAll()
        if let _ = ApplicationContext.shared.profileManager.addressInfo {
            contactRows += [ .mailingAddress ]
        }
        if let _ = ApplicationContext.shared.phoneOptionsManager.phonesInfo?.phoneOpts.filter({ $0.isPrimary }).first {
            contactRows += [ .primaryPhone ]
        }
        if let _ = ApplicationContext.shared.phoneOptionsManager.phonesInfo?.phoneOpts.filter({ !$0.isPrimary }).first {
            contactRows += [ .secondaryPhone ]
        }
        
        if let _ = ApplicationContext.shared.profileManager.profileInfo {
            contactRows += [
                .loginEmail,
                .policyEmail
            ]
        }
        passwordRows = [ .password ]
        
        tableView.reloadData()
    }
    
    func showSuccessBanner() {
        let slidableAlertView = SlidableAlertView.create(withMessage: NSLocalizedString("profile.app.successBanner", comment: ""), type: .update)
        self.baseNavigationController?.addMomentarySupplementaryView(slidableAlertView, animated: true)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionIdentifier = sections[section]
        switch sectionIdentifier {
        case .contact: return contactRows.count
        case .password: return passwordRows.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionIdentifier = sections[indexPath.section]
        switch sectionIdentifier {
        case .contact:
            
            let row = indexPath.row
            let rowIdentifier = contactRows[row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoTableViewCell") as? ProfileInfoTableViewCell {
                switch rowIdentifier {
                case .mailingAddress:
                    cell.titleLbl.text = NSLocalizedString("profile.app.mailingAddress", comment: "")
                    if let address = ApplicationContext.shared.profileManager.addressInfo {
                        let printAddress = "\(address.streetAddress)\n\(address.city), \(address.state) \(address.zip)"
                        cell.descriptionLbl.text = printAddress
                    }
                case .primaryPhone:
                    cell.titleLbl.text = NSLocalizedString("profile.app.primaryPhone", comment: "")
                    if let primaryPhone = ApplicationContext.shared.phoneOptionsManager.phonesInfo?.phoneOpts.filter({ $0.isPrimary }).first {
                        cell.descriptionLbl.text = primaryPhone.formattedOriginalPhone
                    }
                case .secondaryPhone:
                    cell.titleLbl.text = NSLocalizedString("profile.app.secondaryPhone", comment: "")
                    if let secondary = ApplicationContext.shared.phoneOptionsManager.phonesInfo?.phoneOpts.filter({ !$0.isPrimary }).first {
                        cell.descriptionLbl.text = secondary.formattedOriginalPhone
                    }
                case .policyEmail:
                    cell.titleLbl.text = NSLocalizedString("profile.app.policyEmail", comment: "")
                    cell.descriptionLbl.text = ApplicationContext.shared.profileManager.profileInfo?.policyEmailAddress
                case .loginEmail:
                    cell.titleLbl.text = NSLocalizedString("profile.app.loginEmail", comment: "")
                    cell.descriptionLbl.text = ApplicationContext.shared.profileManager.profileInfo?.loginEmailAddress

                }
                return cell
            }
        case .password:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoTableViewCell") as? ProfileInfoTableViewCell {
                cell.titleLbl.text = NSLocalizedString("profile.app.password", comment: "")
                cell.descriptionLbl.text = ""
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionIdentifier = sections[section]
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProfileSectionHeader.identifier) as! ProfileSectionHeader
        switch sectionIdentifier {
        case .contact:
            cell.topLine.isHidden = true
            cell.lblTitle.text = NSLocalizedString("profile.app.contact", comment: "")
            cell.editTouched = { [weak self] in
                self?.performSegue(withIdentifier: SegueMap.contactEdit, sender: self)
            }
            
        case .password:
            cell.lblTitle.text = NSLocalizedString("profile.app.contactDetails", comment: "")
            cell.editTouched = { [weak self] in
                self?.performSegue(withIdentifier: SegueMap.passwordEdit, sender: self)
            }
        }
        return cell
    }
    
}

extension ProfileTableVC {
    
    enum ProfileSectionConfig {
        case contact
        case password
    }
    
    enum ContactRowConfig {
        case mailingAddress
        case primaryPhone
        case secondaryPhone
        case policyEmail
        case loginEmail
    }
    
    enum PasswordRowConfig {
        case password
    }
}
