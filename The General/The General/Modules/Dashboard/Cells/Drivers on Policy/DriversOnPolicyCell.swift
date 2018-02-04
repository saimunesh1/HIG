//
//  DriversOnPolicyCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class DriversOnPolicyCell: UITableViewCell, UITableViewDelegate {
    enum CellIdentifier: String {
        case driverList = "PolicyDriversCell"
        case footer = "RoadsideAssistanceCell"
        
        static func allObjectStrings() -> [String] {
            return [
                self.driverList.rawValue,
                self.footer.rawValue
            ]
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    
    var dashboardInfo: DashboardResponse? {
        didSet {
            tableView.reloadData()
        }
    }
}

extension DriversOnPolicyCell: UITableViewDataSource {
    override func awakeFromNib() {
        CellIdentifier.allObjectStrings().forEach() {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dashboardInfo = dashboardInfo,
            let drivers = dashboardInfo.driverInfo,
            let vehicles = dashboardInfo.vehicleInfo
            else { return 1 }
        
        var rowCount = 1
        var rowHeights = CGFloat(max(drivers.count, vehicles.count) + 1) * 44.0 // Calculate sub view height

        if dashboardInfo.hasRoadsideAssistanceFlag {
            rowCount += 1
            rowHeights += 64
        }

        tableViewHeightConstraint.constant = rowHeights

        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let rowCount = tableView.numberOfRows(inSection: 0)
        
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.driverList.rawValue, for: indexPath) as! PolicyDriversCell
            cell.dashboardInfo = dashboardInfo
            return cell
        } else if let dashboardInfo = dashboardInfo, dashboardInfo.hasRoadsideAssistanceFlag, row == (rowCount - 1) {
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifier.footer.rawValue, for: indexPath) as! RoadsideAssistanceCell
        }
        
        return UITableViewCell()
    }
}
