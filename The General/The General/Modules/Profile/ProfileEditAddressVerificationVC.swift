//
//  ProfileEditAddressVerificationVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 29/12/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ProfileEditAddressVerificationVC: UIViewController {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblYouHaveEnteredTitle: UILabel!
    @IBOutlet weak var lblEnteredAddress: UILabel!
    @IBOutlet weak var lblSelectBestMatch: UILabel!
    @IBOutlet weak var tblViewAddressList: UITableView!
    @IBOutlet weak var btnContinueWithAddress: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    fileprivate var selectedAddressIndexPath: IndexPath? {
        didSet {
            self.tblViewAddressList.reloadData()
            self.enableOrDisableSaveButton()
        }
    }
        
    var addressResponse: SearchAddressResponse? {
        didSet {
            self.tblViewAddressList.reloadData()
        }
    }
    
    var addressRequest: AddressRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    //MARK: Private Helpers
    fileprivate func setupUI() {
        tblViewAddressList.tableFooterView = UIView()

        self.viewBackground.layer.cornerRadius = 8.0
        self.btnCancel.backgroundColor = UIColor.white
        self.btnCancel.layer.borderColor = UIColor.tgGreen.cgColor
        self.btnCancel.layer.borderWidth = 2.0
        self.btnCancel.layer.cornerRadius = self.btnCancel.frame.height / 2.0
        self.btnSave.layer.cornerRadius = self.btnCancel.frame.height / 2.0
        self.enableOrDisableSaveButton()
        
        if let searchResponse = ApplicationContext.shared.profileManager.searchAddressInfo {
            self.addressResponse = searchResponse
        }
        
        if let address = addressRequest {
            lblEnteredAddress.text = "\(address.streetAddress)\n\(address.city), \(address.state) \(address.zip)"
        }
    }
    
    fileprivate func enableOrDisableSaveButton() {
        if let _ = selectedAddressIndexPath {
            self.btnSave.backgroundColor = UIColor.tgGreen
            self.btnSave.isUserInteractionEnabled = true
        } else {
            self.btnSave.backgroundColor = UIColor.tgGray
            self.btnSave.isUserInteractionEnabled = false
        }
    }

    
    // MARK: - Button Actions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        if let request = addressRequest {
            self.updateAddress(with: request)
        }
    }
    
    // On save clicked use the moniker of the selected item and do step in
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let index = selectedAddressIndexPath, let response = addressResponse {
            let moniker = response.addressList[index.row].moniker
            LoadingView.show()
            ApplicationContext.shared.profileManager.stepInAddress(with: moniker, completion: { [weak self] (innerClosure) in
                guard let sSelf = self else { return }
                if let response = try? innerClosure() {
                    // If perfect match, update, else refine
                    if response.singleAddress {
                        let newUpdate = sSelf.build(from: response)
                        sSelf.updateAddress(with: newUpdate)
                    } else {
                        sSelf.refineAddress(with: response)
                    }
                }
            })
        }
    }
    
    private func updateAddress(with request: AddressRequest) {
        ApplicationContext.shared.profileManager.updateAddressDetails(with: request) { [weak self] (innerClosure) in
            guard let sSelf = self else { return }
            LoadingView.hide()
            if let response = try? innerClosure() {
                if response.success {
                    if let baseVc = sSelf.navigationController?.viewControllers.filter({ $0 is ProfileTableVC }).first {
                        let profileTableVC = baseVc as? ProfileTableVC
                        sSelf.navigationController?.isNavigationBarHidden = false
                        sSelf.navigationController?.popToViewController(baseVc, animated: true)
                        profileTableVC?.showSuccessBanner()
                    }
                }
            }
        }
    }
    
    private func refineAddress(with response: SearchAddressResponse) {

        let moniker = response.addressList.first?.moniker ?? ""
        // TODO: determine how to actually get this value
        let refinement = String(response.addressList.first?.text.split(separator: " ").first ?? "")
        
        ApplicationContext.shared.profileManager.refineAddress(with: moniker, refinement: refinement) { [weak self] (innerClosure) in
            guard let sSelf = self else { return }
            if let addressResp = try? innerClosure() {
                let addressRequest = sSelf.build(from: addressResp)
                sSelf.updateAddress(with: addressRequest)
            }
        }
    }
    
    private func build(from response: SearchAddressResponse) -> AddressRequest {
        return AddressRequest(city: response.address?.city ?? "",
                              state: response.address?.state ?? "",
                              streetAddress: response.address?.streetAddress ?? "",
                              zip: response.address?.zip ?? "")
    }
}

extension ProfileEditAddressVerificationVC: UITableViewDataSource, UITableViewDelegate {
    
    
    // MARK: - Table view data source
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressResponse?.addressList.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressVerificationTableViewCell") as! AddressVerificationTableViewCell
        // TODO: Update address to be dynamic
        let refinedAddress = addressResponse?.addressList[indexPath.row]
        cell.lblAddress.text = refinedAddress?.partialAddress
        
        if let refSelectedAddressIndexPath = selectedAddressIndexPath, indexPath == refSelectedAddressIndexPath {
            cell.showSelection(true)
        } else {
            cell.showSelection(false)
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let cell = tableView.cellForRow(at: indexPath) as? AddressVerificationTableViewCell {
            self.selectedAddressIndexPath = cell.imgViewSelection.isHidden ? indexPath : nil
        }
    }
}
