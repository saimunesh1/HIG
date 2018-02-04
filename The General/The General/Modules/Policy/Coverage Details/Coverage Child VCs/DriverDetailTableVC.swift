//
//  DriverDetailTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/8/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class DriverDetailTableVC: UITableViewController {
    
    var driver: DriversResponse? {
        didSet {
            self.updateCells()
            tableView.reloadData()
        }
    }
    
    var sections: [DriverDetailConfig] = []
    var cells: [DriverDetailRowConfig] = []
    
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
    }
    
    private func updateCells() {
        
        sections.removeAll()
        cells.removeAll()
        
        sections += [.driverDetails]
        
        if let discounts = driver?.discounts, discounts.count > 0 {
            sections += [.discounts]
        }
        if let violations = driver?.violations, violations.count > 0 {
            sections += [.violations]
        }
        
        cells += [
                    .type,
                    .relation,
                    .dob,
                    .gender,
                    .marital,
                    .ssn
        ]
        if let _ = driver?.licenseDate {
            cells += [ .licenseDate ]
        }
        if let _ = driver?.dateFirstLicenseConvert {
            cells += [ .firstLicense ]
        }
        cells += [
                    .licenseNo,
                    .licenseState,
        ]
        if let _ = driver?.srFrFiling {
            cells += [.srFrFiling]
        }
    }

    @IBAction func backTouched(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? SupportVC {
			vc.contextualHelpString = NSLocalizedString("contextualhelp.driversdiscounts", comment: "")
		}
	}

}

extension DriverDetailTableVC {
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionIdentifier = sections[section]
        switch sectionIdentifier {
        case .driverDetails: return cells.count
        case .discounts: return driver?.discounts?.count ?? 0
        case .violations: return driver?.violations?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionIdentifier = sections[indexPath.section]
        
        switch sectionIdentifier {
        case .driverDetails:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailInfoCell", for: indexPath) as! DetailInfoCell
            guard let driver = driver else { break }
            let identifier = cells[indexPath.row]
            switch identifier {
            case .type:
                cell.lblTitle.text = NSLocalizedString("driverdetails.type", comment: "")
                cell.lblValue.text = driver.driverType
            case .relation:
                cell.lblTitle.text = NSLocalizedString("driverdetails.relation", comment: "")
                cell.lblValue.text = driver.relationToInsured
            case .dob:
                cell.lblTitle.text = NSLocalizedString("driverdetails.dateofbirth", comment: "")
                cell.lblValue.text = DateFormatter.monthDayYear.string(from: driver.dob)
            case .gender:
                cell.lblTitle.text = NSLocalizedString("driverdetails.gender", comment: "")
                cell.lblValue.text = driver.gender
            case .marital:
                cell.lblTitle.text = NSLocalizedString("driverdetails.maritalstatus", comment: "")
                cell.lblValue.text = driver.maritalStatus
            case .ssn:
                cell.lblTitle.text = NSLocalizedString("driverdetails.ssn", comment: "")
                cell.lblValue.text = driver.maskedSsn
            case .licenseDate:
                cell.lblTitle.text = NSLocalizedString("driverdetails.licenseissue", comment: "")
                if let licenseDate = driver.licenseDate, let date = DateFormatter.iso8601.date(from: licenseDate) {
                    cell.lblValue.text = DateFormatter.monthDayYear.string(from: date)
                } else {
                    cell.lblValue.text = "-"
                }
            case .firstLicense:
                cell.lblTitle.text = NSLocalizedString("driverdetails.licensefirst", comment: "")
                if let licenseDate = driver.dateFirstLicenseConvert, let date = DateFormatter.iso8601.date(from: licenseDate) {
                    cell.lblValue.text = DateFormatter.monthDayYear.string(from: date)
                } else {
                    cell.lblValue.text = "-"
                }
            case .licenseNo:
                cell.lblTitle.text = NSLocalizedString("driverdetails.licensenum", comment: "")
                cell.lblValue.text = driver.maskedLicenseNo ?? "-"
            case .licenseState:
                cell.lblTitle.text = NSLocalizedString("driverdetails.licensestate", comment: "")
                cell.lblValue.text = driver.licenseState
            case .srFrFiling:
                cell.lblTitle.text = NSLocalizedString("driverdetails.srfr", comment: "")
                cell.lblValue.text = driver.srFrFiling
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            return cell
            
        case .discounts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath) as! InformationCell
            guard let discounts = driver?.discounts else { break }
            cell.lblTitle.text = discounts[indexPath.row].description
            return cell

        case .violations:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DriverViolationsCell", for: indexPath) as! DriverViolationsCell
            guard let violations = driver?.violations else { break }
            cell.driverViolation = violations[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionIdentifier = sections[section]
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeader.identifier) as! SectionHeader
        switch sectionIdentifier {
        case .driverDetails:
            if let driver = driver {
                cell.lblTitle?.text = driver.firstName + " " + driver.lastName
            }
        case .discounts:
            cell.lblTitle.text = NSLocalizedString("driverdetails.discounts", comment: "")
        case .violations:
            cell.lblTitle.text = NSLocalizedString("driverdetails.violations", comment: "")
        }
        return cell
    }

}

extension DriverDetailTableVC {
    
    enum DriverDetailConfig: Int {
        case driverDetails
        case discounts
        case violations
    }
    
    enum DriverDetailRowConfig {
        case type
        case relation
        case dob
        case gender
        case marital
        case ssn
        case licenseDate
        case firstLicense
        case licenseNo
        case licenseState
        case srFrFiling
    }
}

fileprivate enum CellIdentifier: String {
    case coverageInfo = "DetailInfoCell"
    case discountInfo = "InformationCell"
    case driverViolation = "DriverViolationsCell"
    
    static func allObjectStrings() -> [String] {
        return [
            self.coverageInfo.rawValue,
            self.discountInfo.rawValue,
            self.driverViolation.rawValue
        ]
    }
}
