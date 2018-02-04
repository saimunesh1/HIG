//
//  CountryPickVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/12/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class CountryPickVC: FNOLBaseVC, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var callback: ((String) -> ())?
    let countryDictionary: [String: String] = [
        "USA": "Unites States of America",
        "CA": "Canada",
        "MX": "Mexico",
       ]
    
    var selecteVehicle: VehicleInfo?
    var arr_name = NSArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .clear
        self.tableView.register(PickerViewCell.nib, forCellReuseIdentifier: PickerViewCell.identifier)
        arr_name = Array(countryDictionary.keys) as NSArray
        tableView.tableFooterView = UIView()

    }
    
    // number of rows in table view
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_name.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PickerViewCell.identifier, for: indexPath) as! PickerViewCell
        cell.titleLabel?.text = arr_name.object(at: indexPath.row) as? String
        cell.checkImageView.isHidden = true
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountry = arr_name.object(at: indexPath.row) as? String
        callback!(selectedCountry!)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension CountryPickVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}
