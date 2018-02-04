//
//  VehicleDetailTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/8/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class VehicleDetailTableVC: UITableViewController {
    
    var sections: [VehicleDetailConfig] = []
    var vehicleInfoCells: [VehicleDetailRowConfig] = []
    var vehicleCoverageCells: [VehicleCoverageRowConfig] = []
    
    var vehicle: VehicleResponse? {
        didSet {
            self.updateCells()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setupCells()
    }
   
    private func setupCells() {
        CellIdentifier.allObjectStrings().forEach() {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
        tableView.register(SectionHeader.nib, forHeaderFooterViewReuseIdentifier: SectionHeader.identifier)
        tableView.register(SectionHeaderChart.nib, forHeaderFooterViewReuseIdentifier: SectionHeaderChart.identifier)
    }
    
    private func updateCells() {
        
        sections.removeAll()
        vehicleInfoCells.removeAll()
        vehicleCoverageCells.removeAll()
        
        sections += [.vehicleDetails]
        
        vehicleInfoCells += [
            .vin,
            .collision,
            .leased,
            .premium,
        ]
        if let _ = vehicle?.owner {
            vehicleInfoCells += [ .owner ]
        }
        if let _ = vehicle?.coOwner {
            vehicleInfoCells += [ .co_owner ]
        }
        
        if let vehicleCoverages = vehicle?.vehicleCoverages, vehicleCoverages.count > 0 {
            sections += [.coverage]
            for _ in vehicleCoverages {
                vehicleCoverageCells += [.coverage]
            }
        }
        vehicleCoverageCells += [.footer]
        
        if let vehicleDiscounts = vehicle?.discounts, vehicleDiscounts.count > 0 {
            sections += [.discounts]
        }
        
        if let vehicleLeinHolders = vehicle?.lienholders, vehicleLeinHolders.count > 0 {
            sections += [.leinHolder]
        }
        tableView.reloadData()
    }
    
    @IBAction func backTouched(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let identifier = sections[section]
        switch identifier {
        case .vehicleDetails: return vehicleInfoCells.count
        case .coverage: return vehicleCoverageCells.count
        case .discounts: return vehicle?.discounts?.count ?? 0
        case .leinHolder: return vehicle?.lienholders?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionIdentifier = sections[indexPath.section]
        
        switch sectionIdentifier {
        case .vehicleDetails:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailInfoCell", for: indexPath) as? DetailInfoCell else { break }
            let identifier = vehicleInfoCells[indexPath.row]
            switch identifier {
            case .vin:
                cell.lblTitle.text = NSLocalizedString("vehicledetails.vin", comment: "Vehicle Identification Number (VIN)")
                cell.lblValue.text = vehicle?.vin
            case .collision:
                cell.lblTitle.text = NSLocalizedString("vehicledetails.collision", comment: "Comprehensive/collision deductible")
                cell.lblValue.text = vehicle?.compCollisionDesc
            case .leased:
                cell.lblTitle.text = NSLocalizedString("vehicledetails.leased", comment: "Vehicle leased?")
                cell.lblValue.text = vehicle?.leased
            case .premium:
                cell.lblTitle.text = NSLocalizedString("vehicledetails.premium", comment: "Vehicle premium")
                cell.lblValue.text = "$\(vehicle?.premium ?? "")"
            case .owner:
                cell.lblTitle.text = NSLocalizedString("vehicledetails.owner", comment: "Registered owner")
                cell.lblValue.text = vehicle?.owner
            case .co_owner:
                cell.lblTitle.text = NSLocalizedString("vehicledetails.coowner", comment: "Co-owner")
                cell.lblValue.text = vehicle?.coOwner
            
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell

        case .coverage:
            
            let identifier = vehicleCoverageCells[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleCoverageInfoCell", for: indexPath) as? VehicleCoverageInfoCell else { break }

            switch identifier {
            case .coverage:
                if let coverage = vehicle?.vehicleCoverages[indexPath.row] {
                    cell.lblTitle.text = coverage.description
                    cell.lblTitle.font = UIFont.largeText
                    cell.lblDeductible.text = coverage.deductible
                    cell.lblPremium.text = coverage.premium
                    cell.lblPremium.font = UIFont.largeText
                }
            case .footer:
                cell.lblTitle.text = NSLocalizedString("vehicledetails.totalpremium", comment: "")
                cell.lblTitle.font = UIFont.boldTitle
                cell.lblDeductible.text = ""
                cell.lblPremium.text = "$\(vehicle?.premium ?? "")"
                cell.lblPremium.font = UIFont.boldTitle

            }
            return cell

        case .discounts:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath) as? InformationCell else { break }
            if let discount = vehicle?.discounts?[indexPath.row] {
                cell.lblTitle.text = discount.description
            }
            return cell
            
        case .leinHolder:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeinHolderCell", for: indexPath) as? LeinHolderCell else { break }
            if let leinHolder = vehicle?.lienholders?[indexPath.row] {
                cell.leinHolder = leinHolder
            }
            return cell
        }

        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionIdentifier = sections[section]
        
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeader.identifier) as! SectionHeader
        
        switch sectionIdentifier {
        case .vehicleDetails:
            if let vehicle = vehicle {
                cell.lblTitle?.text = "\(vehicle.year) \(vehicle.description)"
            }
        case .coverage:
            let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderChart.identifier) as! SectionHeaderChart
            cell.lblTitle?.text = NSLocalizedString("vehicledetails.coverage", comment: "")
            return cell
        case .discounts:
            cell.lblTitle?.text = NSLocalizedString("vehicledetails.discounts", comment: "")
        case .leinHolder:
            cell.lblTitle?.text = NSLocalizedString("vehicledetails.leinholder", comment: "")
        }
        return cell
    }
}

extension VehicleDetailTableVC {
    
    enum VehicleDetailConfig: Int {
        case vehicleDetails
        case coverage
        case discounts
        case leinHolder
    }
    
    enum VehicleDetailRowConfig {
        case vin
        case collision
        case leased
        case premium
        case owner
        case co_owner
    }
    
    enum VehicleCoverageRowConfig {
        case coverage
        case footer
    }
}

fileprivate enum CellIdentifier: String {
    case vehicleInfo = "DetailInfoCell"
    case driverViolations = "VehicleCoverageInfoCell"
    case discounts = "InformationCell"
    case leinHolder = "LeinHolderCell"
    
    static func allObjectStrings() -> [String] {
        return [
            self.vehicleInfo.rawValue,
            self.driverViolations.rawValue,
            self.discounts.rawValue,
            self.leinHolder.rawValue
        ]
    }
}
