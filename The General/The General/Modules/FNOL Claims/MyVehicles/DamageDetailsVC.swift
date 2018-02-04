//
//  DamageDetailsVC.swift
//  The General
//
//  Created by Michael Moore on 10/27/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class DamageDetailsVC: UITableViewController {
    
    private var accidentType = ""
    private var accidentSubType = ""
    var viewModel: Questionnaire!
    var currentPage: Page?
    var currentField: Field?
    var fields: [Field] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var footerHeight: CGFloat = 120.0
    var separatorInset: CGFloat = 12.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let type = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "accidentDetails.whatHappened.type") else {
            return
        }
        guard let subType = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "accidentDetails.whatHappened.subType") else {
            return
        }
        accidentType = type
		accidentSubType = subType
        setupViews()
        prepareDamageDetails()
    }
    
    func setupViews() {
        tableView.register(SegmentedControlTableViewCell.nib, forCellReuseIdentifier: SegmentedControlTableViewCell.identifier)
        tableView.register(DoneFooterTableViewCell.nib, forHeaderFooterViewReuseIdentifier: DoneFooterTableViewCell.identifier)
        tableView.separatorInset.left = separatorInset
        tableView.separatorInset.right = separatorInset
        tableView.separatorColor = .tgGray
    }
    
    func prepareDamageDetails() {
        guard let page: Page = viewModel?.getPageForId(id: "my_vehicle_details") else {
            return
        }
        currentPage = page
        guard let pageID =  currentPage?.pageId,
            let sectionList = viewModel?.getSectionList(pageID: pageID),
            let currentSection = sectionList.first
            else {
                return
        }
        
        currentField = currentSection.fieldsArray?.first { $0.typeEnum == .damageDetailPickList }
        title = currentField?.title
        
        // Check for subfields and Rules to check respective damaged details associated with accident type
		// Here, subFieldsArray is all of the questions that could be asked. We need to narrow it down to the
		// questions appropriate to the accident type and subtype.
        for subfield in (currentField?.subFieldsArray)! {
			
			// Each question has associated rules. Each rule has a parentFieldResponseKey (what parent responseKey to look at)
			// and an array of values (parentValuesArray: the values to check for in that parent responseKey)
            for rule in (subfield.rulesArray)! {
                if let matchesParentValue = rule.parentValuesArray?.contains(where: { (parentValue) in
                    guard let parentValueCode = parentValue.value?.code else { return false }
                    return parentValueCode == accidentType || parentValueCode == accidentSubType
                }) {
                    if matchesParentValue {
                        fields.append(subfield)
                    }
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func instantiate() -> DamageDetailsVC {
        let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! DamageDetailsVC
        return vc
    }
    
    @IBAction func goBack(segue: UIStoryboardSegue) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DamageDetailsVC {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? fields.count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = fields[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedControlTableViewCell.identifier, for: indexPath) as! SegmentedControlTableViewCell
        cell.field = field
        cell.delegate = self
        // pre select the Segement button if already found the value from Active Cliam.
        if let responseKey = field.responseKey, let value = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey:responseKey) {
            if let index = cell.responseCodes?.index(of: value) {
                cell.cellSegmentControl.selectedIndex = index
            }
        }
		return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 1 ? footerHeight : 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: DoneFooterTableViewCell.identifier) as! DoneFooterTableViewCell
        let border = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0.5))
        border.backgroundColor = .tgGray
        footerCell.addSubview(border)
        footerCell.delegate = self
        return footerCell
    }
}

extension DamageDetailsVC: SegmentedControlTableViewCellDelegate {
    func didSwitch(index: Int, row: Row?) {
    }
    
    func segmentValueChanged(field: Field, value: String) {
        if let responseKey = field.responseKey {
			ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(value, displayValue: nil, forResponseKey: responseKey)
        }
    }
}

extension DamageDetailsVC: DamageDetailsFooterDelegate {
    func touchOnDone() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DamageDetailsVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}
