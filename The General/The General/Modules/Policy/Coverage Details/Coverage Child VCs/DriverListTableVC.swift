//
//  DriverListTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 09/01/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

fileprivate enum CellIdentifier: Int {

    case driverInfo

    var value: String {
        switch self {
        case .driverInfo: return "OpenDetailCell"
        }
    }
    
    static func allObjectStrings() -> [String] {
        return [
            self.driverInfo.value,
        ]
    }
}

class DriverListTableVC: UITableViewController {
    
    private var cells: [CellIdentifier] = []
    
    private struct SegueMap {
        static let driverDetail = "driverDetail"
    }
    private var activeDriverList: [DriversResponse]?
    private var excludedDriverList: [DriversResponse]?
    
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
    
    func updateCells() {
        
        if let driverInfo = ApplicationContext.shared.policyManager.driverInfo {
            activeDriverList = driverInfo.filter({ return $0.driverStatus == "Active Driver" })
            excludedDriverList = driverInfo.filter({ return $0.driverStatus != "Active Driver" })
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == SegueMap.driverDetail {
                if let driverDetailVC = segue.destination as? DriverDetailTableVC {
                    // TODO change
                    driverDetailVC.driver = activeDriverList?[0]
                }
            }
        }
    }
}


extension DriverListTableVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var sectionCount = 0
        if let _ = activeDriverList {
            sectionCount += 1
        }
        if let list = excludedDriverList, list.count > 0 {
            sectionCount += 1
        }
        return sectionCount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return activeDriverList?.count ?? 0
        case 1:
            return excludedDriverList?.count ?? 0
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenDetailCell", for: indexPath)
        guard let driverCell = cell as? OpenDetailCell else { return UITableViewCell() }
        switch indexPath.section {
        case 0:
            if let driverObject = activeDriverList?[indexPath.row] {
                driverCell.lblTitle.text = driverObject.firstName + " " + driverObject.lastName
            }
        case 1:
            if let driverObject = excludedDriverList?[indexPath.row] {
                driverCell.lblTitle.text = driverObject.firstName + " " + driverObject.lastName
            }
        default: break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeader.identifier) as! SectionHeader
        switch section {
        case 0:
            guard let _ = activeDriverList else { return nil }
            cell.lblTitle?.text = NSLocalizedString("driverdetails.active", comment: "")
        case 1:
            guard let list = excludedDriverList, list.count != 0 else { return nil }
            cell.lblTitle?.text = NSLocalizedString("driverdetails.excluded", comment: "")
        default: break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: SegueMap.driverDetail, sender: self)
    }
}
