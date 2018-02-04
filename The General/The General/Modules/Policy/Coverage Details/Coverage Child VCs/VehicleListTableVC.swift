//
//  VehicleDetailTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 06/01/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

fileprivate enum CellIdentifier: Int {
    case vehicleInfo
    
    var value: String {
        switch self {
        case .vehicleInfo: return "VehicleInfoCell"
        }
    }
    
    static func allObjectStrings() -> [String] {
        return [
            self.vehicleInfo.value,
        ]
    }
}


class VehicleListTableVC: UITableViewController {
    
    private struct SegueMap {
        static let vehicleDetail = "vehicleDetail"
    }
    private var cells: [CellIdentifier] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setupCells()
        
    }
    
    private func setupCells() {
        CellIdentifier.allObjectStrings().forEach() {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
    }
    
    func updateCells() {
        if let vehiclesInfo = ApplicationContext.shared.policyManager.vehicleInfo {
            cells.removeAll()
            for _ in vehiclesInfo {
                cells += [
                    .vehicleInfo,
                ]
            }
            
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vehicleDetailObj = segue.destination as? VehicleDetailTableVC {
            vehicleDetailObj.vehicle = sender as? VehicleResponse
        }
    }
}


extension VehicleListTableVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cellIdentifier = cells[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.value, for: indexPath)
        
        switch cellIdentifier {
        case .vehicleInfo:
            guard let vehiclecell = cell as? VehicleInfoCell else { break }
            let vehicleObj = ApplicationContext.shared.policyManager.vehicleInfo![indexPath.row]
            vehiclecell.vehicleName.text = "\(vehicleObj.year) \(vehicleObj.description)"
            vehiclecell.vehicleLicense.text = vehicleObj.licensePlate ?? ""
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedVehicle = ApplicationContext.shared.policyManager.vehicleInfo?[indexPath.row]
        performSegue(withIdentifier: SegueMap.vehicleDetail, sender: selectedVehicle)
    }
}
