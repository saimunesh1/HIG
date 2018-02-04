//
//  PolicyDriversCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PolicyDriversCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    enum DriversCellIdentifier: String {
        case header = "DriversHeaderCell"
        case driver = "DriversEntryCell"

        static func allObjectStrings() -> [String] {
            return [
                self.header.rawValue,
                self.driver.rawValue,
            ]
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    var dashboardInfo: DashboardResponse? {
        didSet {
            tableView.reloadData()
        }
    }

    override func awakeFromNib() {
        DriversCellIdentifier.allObjectStrings().forEach() {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dashboardInfo = dashboardInfo,
            let drivers = dashboardInfo.driverInfo,
            let vehicles = dashboardInfo.vehicleInfo
            else { return 1 }
        
        let rowCount = max(drivers.count, vehicles.count) + 1
        let rowHeights = CGFloat(rowCount) * 44.0
        
        tableHeightConstraint.constant = rowHeights
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: DriversCellIdentifier.header.rawValue, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: DriversCellIdentifier.driver.rawValue, for: indexPath) as! DriversEntryCell
            let index = row - 1
            
            if let drivers = dashboardInfo?.driverInfo, index < drivers.count {
                let driver = drivers[index]
                cell.driverLabel.text = "\(driver.firstName) \(driver.middleInitial ?? "") \(driver.lastName)"
            }
            
            if let vehicles = dashboardInfo?.vehicleInfo, index < vehicles.count {
                let vehicle = vehicles[index]
                cell.vehicleLabel.text = "\(vehicle.year) \(vehicle.make) \(vehicle.model)"
            }
            
            return cell
        }
    }
}
