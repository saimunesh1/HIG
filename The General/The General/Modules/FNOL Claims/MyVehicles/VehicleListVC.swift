//
//  VehicleListVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import MagicalRecord

class VehicleListVC: FNOLBaseVC, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    public var callbackForVehicleInfo: ((FNOLVehicle) -> ())?
    public var colourArray: [String] = []
    public var selectedVehicle: FNOLVehicle? = nil
    public var selecteColour: String?
    public var callback: ((FNOLVehicle) -> ())?
    public var viewModel: Questionnaire?
    public var sectionFields: [Field]?
    public var currentSection: Section?

    private var vehicleList: [FNOLVehicle]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(VehicleListCell.nib, forCellReuseIdentifier: VehicleListCell.identifier)
        self.tableView.register(VehicleListFooter.nib, forHeaderFooterViewReuseIdentifier: VehicleListFooter.identifier)
        guard let list = self.viewModel?.getSectionList(pageID: "my_vehicle_details") else {
            return
        }
        //TODO -  Workaround for hiding Colour field
        sectionFields = list.first?.fields?.filter{($0 as! Field).typeEnum == .vehiclePickList} as? [Field]
        currentSection = list.first
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // If we don't have any vehicleInfo objects yet, create them from the VehicleInfo objects in the Questionnaire
		guard let activeClaim = ApplicationContext.shared.fnolClaimsManager.activeClaim else { return }
		let predicate: NSPredicate = NSPredicate(format: "claim == %@", activeClaim)
		let fnolVehicles = (FNOLVehicle.mr_findAll(with: predicate) as? [FNOLVehicle]) ?? []
        if fnolVehicles.isEmpty {
            let vehicleInfos = (VehicleInfo.mr_findAll() as? [VehicleInfo]) ?? []
            for vehicleInfo in vehicleInfos {
                let fnolVehicle = FNOLVehicle.mr_createEntity()!
                ApplicationContext.shared.fnolClaimsManager.activeClaim?.addVehicle(fnolVehicle)
                fnolVehicle.populateFrom(vehicleInfo: vehicleInfo)
            }
        }
        LoadingView.show(inView: self.view, type: .hud, animated: true)
        loadAccidentVehicleListFromCoreData {
            self.tableView.reloadData()
        }
        LoadingView.hide(inView: self.view, animated: true)
    }

    private func loadAccidentVehicleListFromCoreData(completion: (() -> Void)?) {
		guard let activeClaim = ApplicationContext.shared.fnolClaimsManager.activeClaim else { return }
		let predicate: NSPredicate = NSPredicate(format: "claim == %@", activeClaim)
		vehicleList = (FNOLVehicle.mr_findAll(with: predicate) as? [FNOLVehicle]) ?? []
        completion?()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "showVehicleInfoVC" {
            let vc  = segue.destination as! VehicleInfoVC
            let selectedField = sender as? Field
            vc.selectedField = selectedField
            vc.currentSection = self.currentSection
            vc.delegate = self
         } else if (segue.identifier == "showPickMakeModelVC") {
            let vc = segue.destination as! PickMakeModelVC
            vc.navigationItem.title = "Colour"
            vc.dataSourceArray = self.colourArray
            /// update vehicles to the list
            vc.callback = { (value) in
                self.selecteColour = value
                self.callbackForVehicleInfo!(self.selectedVehicle!)
                self.navigationController?.popViewController(animated: true)
            }
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VehicleListCell.identifier, for: indexPath) as! VehicleListCell
        cell.checkImageView.isHidden = true
        cell.vehicleLabel.text = "\( vehicleList![indexPath.row].year ?? "") \( vehicleList![indexPath.row].make ?? "")  \(vehicleList![indexPath.row].model ?? "")   \(vehicleList![indexPath.row].licensePlate ?? "")".lowercased().capitalized
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  (vehicleList!.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let  footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: VehicleListFooter.identifier) as! VehicleListFooter
        footerCell.delegate = self
        return  footerCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vehicle = self.vehicleList![indexPath.row]
        self.selectedVehicle = vehicle

        //After selection force user to pick Colour
        self.pickVehicleColour()
    }

    
    /// Pick colour after Vehicle Selection
    func pickVehicleColour() {
        self.colourArray.removeAll()
        /// Colour is not part of the Vehicle object, so custom field
        guard let colourField: [Field] = (currentSection?.fields?.filter{($0 as? Field)?.typeEnum == .pickList} as? [Field]) else{
            return
        }
        let fld = colourField.first
        for valObj in (fld?.validValues)! {
            self.colourArray.append((valObj as! Value).value!)
        }
        LoadingView.hide(inView: self.view, animated: true)
        self.performSegue(withIdentifier: "showPickMakeModelVC", sender: self)
    }
    
}

extension VehicleListVC: VehicleListFooterDelegate {
    
    func didTouchonAddVehicle(vehicle: FNOLVehicle) {
        self.selectedVehicle = vehicle
        self.callbackForVehicleInfo?(self.selectedVehicle!)
        self.navigationController?.popViewController(animated: true)
    }

    func didTouchonSaveExit(isSave: Bool) {
        print("onSave")
    }
    
    func didTouchonOtherVehicle() {
       self.performSegue(withIdentifier: "showVehicleInfoVC", sender: sectionFields?.first)
    }
    
}

extension VehicleListVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}
