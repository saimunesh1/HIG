//
//  PickMakeModelVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/31/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PickMakeModelVC: FNOLBaseVC, UITableViewDataSource, UITableViewDelegate  {

	@IBOutlet var tableView: UITableView!
	@IBOutlet weak var searchBar: UISearchBar!
	
    public var callback: ((String) -> ())?
    public var dataSourceArray = [String]()
	
    private var arrIndexSection = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	private var filteredDataSourceArray = [String]()
	private var searchActive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.register(PickerViewCell.nib, forCellReuseIdentifier: PickerViewCell.identifier)
        tableView.tableFooterView = UIView()
		searchBar.delegate = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		filteredDataSourceArray = dataSourceArray
	}
	
	private func valuesThatBeginWith(letter: String) -> [String] {
		let valuesThatBeginWithThisLetter = filteredDataSourceArray.filter({
			var include = false
			if $0.count > 0 {
				if String($0.first! as String.Element).uppercased() == letter.uppercased() {
					include = true
				}
			}
			return include
		})
		return valuesThatBeginWithThisLetter
	}
    
    // Side List in tableview
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 26
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.arrIndexSection //Side Section title
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return valuesThatBeginWith(letter: arrIndexSection[section]).count > 0 ? "" : arrIndexSection[section]
    }
    
    // number of rows in table view
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return valuesThatBeginWith(letter: arrIndexSection[section]).count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PickerViewCell.identifier, for: indexPath) as! PickerViewCell
		let matchingValue = valuesThatBeginWith(letter: arrIndexSection[indexPath.section])[indexPath.row]
		cell.titleLabel?.text = matchingValue
        cell.checkImageView.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedValue = valuesThatBeginWith(letter: arrIndexSection[indexPath.section])[indexPath.row]
        callback!(selectedValue)
        self.navigationController?.popViewController(animated: true)
    }
	
}

extension PickMakeModelVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}

extension PickMakeModelVC: UISearchBarDelegate {
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchActive = true;
	}
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		searchActive = false;
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchActive = false;
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchActive = false;
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		filteredDataSourceArray = dataSourceArray.filter({ (text) -> Bool in
			let tmp: NSString = text as NSString
			let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
			return range.location != NSNotFound
		})
		if (filteredDataSourceArray.count == 0) {
			searchActive = false;
		} else {
			searchActive = true;
		}
		self.tableView.reloadData()
	}

}
