//
//  CoverageDetailTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 06/01/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

fileprivate enum CellIdentifier: String {
    case coverageInfo = "CoverageInfoCell"
    case discountInfo = "InformationCell"
    case policyInfo = "DetailInfoCell"
    case policyWarningView = "PendingPolicyAlertViewCell"

    static func allObjectStrings() -> [String] {
        return [
            self.coverageInfo.rawValue,
            self.discountInfo.rawValue,
            self.policyInfo.rawValue,
            self.policyWarningView.rawValue
        ]
    }
}


class CoverageDetailTableVC: UITableViewController {

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
        tableView.register(SectionHeader.nib, forHeaderFooterViewReuseIdentifier: SectionHeader.identifier)
    }
    
    func updateCells() {
        tableView.reloadData()
    }
}

extension CoverageDetailTableVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return CoverageDetailConfig.sectionCount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoverageDetailConfig.rowCount(at: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = CoverageDetailConfig.cellIdentifier(at: indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        switch indexPath.section {
            case CoverageDetailConfig.policyWarning.rawValue:
            guard let cell = cell as? PendingPolicyAlertViewCell else { break }
            
            cell.dashboardResponse = ApplicationContext.shared.dashboardManager.dashboardInfo
            cell.paymentResponse = ApplicationContext.shared.paymentsManager.dueDetails
        case CoverageDetailConfig.coverageDetails.rawValue:
            guard let cell = cell as? CoverageInfoCell else { break }
            if let info = ApplicationContext.shared.policyManager.coverageInfo?.coverages {
                cell.coverageInfo = info[indexPath.row]
            }
            
        case CoverageDetailConfig.discounts.rawValue:
            guard let cell = cell as? InformationCell else { break }
            if let discounts = ApplicationContext.shared.policyManager.coverageInfo?.discounts {
                cell.lblTitle.text = discounts[indexPath.row].description
            }

        case CoverageDetailConfig.policyTerm.rawValue:
            guard let cell = cell as? DetailInfoCell else { break }
            guard let coverage = ApplicationContext.shared.policyManager.coverageInfo?.coveragePolicy else { break }
            cell.lblTitle.text = CoverageDetailConfig.keyValue(at: indexPath.row)
            switch indexPath.row {
                case 0: cell.lblValue.text = DateFormatter.monthDayYear.string(from: coverage.originalEffectiveDate)
                case 1: cell.lblValue.text = DateFormatter.monthDayYear.string(from: coverage.effectiveDate)
                case 2: cell.lblValue.text = DateFormatter.monthDayYear.string(from: coverage.expirationDate)
                case 3: cell.lblValue.text = coverage.payPlan
                default: break
            }
        default: break
        
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeader.identifier) as! SectionHeader
        if section == 0 {
            return nil
        }
        cell.lblTitle?.text = CoverageDetailConfig.title(at: section)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

fileprivate enum CoverageDetailConfig: Int {
    case policyWarning
    case coverageDetails
    case discounts
    case policyTerm
    
    static var sectionCount: Int {
        return 4
    }
    
    static func rowCount(at section: Int) -> Int {
        switch section {
        case 0:
            guard let dashBoardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo, let status = dashBoardInfo.policyStatus else {
                return 0
            }
            
            return (status == .canceled || status == .lapsed) ? 1 : 0
        case 1: return ApplicationContext.shared.policyManager.coverageInfo?.coverages.count ?? 0
        case 2: return ApplicationContext.shared.policyManager.coverageInfo?.discounts.count ?? 0
        case 3: return 4
        default: return 0
        }
    }
    
    static func title(at section: Int) -> String {
        switch section {
        case 1: return NSLocalizedString("coverageDetails.details", comment: "Coverage Details")
        case 2: return NSLocalizedString("coverageDetails.discounts", comment: "Discounts")
        case 3: return NSLocalizedString("coverageDetails.policyterm", comment: "Policy term/pay plan")
        default: return ""
        }
    }
    
    static func cellIdentifier(at section: Int) -> String {
        switch section {
        case 0: return CellIdentifier.policyWarningView.rawValue
        case 1: return CellIdentifier.coverageInfo.rawValue
        case 2: return CellIdentifier.discountInfo.rawValue
        case 3: return CellIdentifier.policyInfo.rawValue
        default: return ""
        }
    }

    static func keyValue(at row: Int) -> String {
        switch row {
        case 0: return NSLocalizedString("coverageDetails.originalEffective", comment: "Original effective date")
        case 1: return NSLocalizedString("coverageDetails.effective", comment: "Effective date")
        case 2: return NSLocalizedString("coverageDetails.expiration", comment: "Expiration date")
        case 3: return NSLocalizedString("coverageDetails.payPlan", comment: "Pay Plan")
        default: return ""
        }
    }
}
