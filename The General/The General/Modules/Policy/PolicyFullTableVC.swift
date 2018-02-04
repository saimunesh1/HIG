//
//  PolicyFullTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit
import SafariServices

fileprivate enum CellIdentifier: Int {
    case policyFullInfo
    case policyProgressLine
    case policyPendingInfo
    case driversOnPolicy
    case paymentDue
    case idCard
    case coverage
    case policy
    case related
    case pendingPolicyAlertView
    case esignView
    case renewPolicy
    case getQuote
    case makePayment
    case underReview
    
    var value: String {
        switch self {
        case .policyFullInfo: return "FullPolicyInfoCell"
        case .policyProgressLine: return "ProgressLineCell"
        case .policyPendingInfo: return "PolicyPendingInfoCell"
        case .driversOnPolicy: return "PolicyDriversCell"
        case .paymentDue: return "PaymentDueCell"
        case .idCard: return "OpenDetailCell"
        case .coverage: return "OpenDetailCell"
        case .policy: return "OpenDetailCell"
        case .related: return "OpenDetailCell"
        case .pendingPolicyAlertView: return "PendingPolicyAlertViewCell"
        case .esignView: return "EsignCell"
        case .renewPolicy: return "PolicyRenewCell"
        case .getQuote: return "GetAQuoteCell"
        case .makePayment: return "MakePaymentCell"
        case .underReview: return "UnderReviewAlertCell"
        }
    }
    
    static func allObjectStrings() -> [String] {
        return [
            self.policyFullInfo.value,
            self.policyProgressLine.value,
            self.policyPendingInfo.value,
            self.driversOnPolicy.value,
            self.paymentDue.value,
            self.idCard.value,
            self.coverage.value,
            self.policy.value,
            self.related.value,
            self.pendingPolicyAlertView.value,
            self.esignView.value,
            self.renewPolicy.value,
            self.getQuote.value,
            self.makePayment.value,
            self.underReview.value
        ]
    }
}


class PolicyFullTableVC: UITableViewController, PolicyNavigatable {
    
    private var cells: [CellIdentifier] = []
    
    struct SegueMap {
        static let coverageSegue = "coverageDetailsSegue"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        setupCells()
        setupInitialState()
    }
    
    private func setupCells() {
        CellIdentifier.allObjectStrings().forEach() {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
        tableView.register(TableHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableHeaderView.identifier)
    }
    
    private func setupInitialState() {
        self.baseNavigationController?.showMenuButton()
        updateCells()
    }
    
    fileprivate func updateCells() {
        
        if let dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo, let dueDetails = ApplicationContext.shared.paymentsManager.dueDetails {
            cells.removeAll()
            if let policyStatus = dashboardInfo.policyStatus {
                if policyStatus == .entry {
                    cells += [
                        .policyFullInfo,
                        .pendingPolicyAlertView,
                        .esignView,
                        .related
                    ]
                } else if policyStatus == .active && !dashboardInfo.isExpiredPolicy {
                    cells += [
                        .policyFullInfo,
                        .policyProgressLine,
                        .driversOnPolicy]
                    if let endDate = dashboardInfo.policyEndDate {
                        // TODO: need to be updated as per requirement, 15 here is the number of days before policy expires.
                        
                        if let days = endDate.daysBetween(), days < 15  {
                            cells += [ .pendingPolicyAlertView, .makePayment ]
                        } else if let currentDueAmount = dashboardInfo.currentDueAmount?.rawValue, currentDueAmount > 0 {
                            cells += [ .paymentDue ]
                        }
                    }
                    cells += [
                        .idCard,
                        .coverage,
                        .policy,
                        .related
                    ]
                } else if policyStatus == .canceled {
                    cells += [
                        .policyFullInfo,
                        .policyProgressLine,
                        .pendingPolicyAlertView,
                        .makePayment,
                        .idCard,
                        .coverage,
                        .policy,
                        .related
                    ]
                } else if policyStatus == .lapsed && !dashboardInfo.isExpiredPolicy {
                    cells += [
                        .policyFullInfo,
                        .policyProgressLine,
                        .driversOnPolicy,
                        .pendingPolicyAlertView
                        ]
                    if dueDetails.canReinstate {
                        cells += [.makePayment]
                    }
                    cells += [
                        .idCard,
                        .coverage,
                        .policy,
                        .related
                    ]
                } else if dashboardInfo.isExpiredPolicy {
                    cells += [
                        .policyFullInfo,
                        .policyProgressLine,
                        .pendingPolicyAlertView,
                        .makePayment
                    ]
                    
                    if let endDate = dashboardInfo.policyEndDate {
                        // TODO: Some states it sould be 60
                        if let days = endDate.daysBetween(), days > 30 {
                            cells += [ .renewPolicy ]
                        } else {
                            cells += [ .getQuote ]
                        }
                        
                        cells += [
                            .idCard,
                            .coverage,
                            .policy,
                            .related
                        ]
                    }
                }
            }
        }
  
        tableView.reloadData()
    }
    
    @IBAction fileprivate func didTouchModifyPolicyButton(_ sender: UIBarButtonItem!) {
        pushModifyPolicyOnNavigationController()
    }
}

extension PolicyFullTableVC {
    
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
        case .policyFullInfo:
            guard let piCell = cell as? FullPolicyInfoCell else { break }
            piCell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
        case .policyProgressLine:
            guard let progCell = cell as? ProgressLineCell else { break }
            progCell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
        case .policyPendingInfo:
            guard let ppiCell = cell as? PolicyPendingInfoCell else { break }
            ppiCell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
        case .driversOnPolicy:
            guard let dopCell = cell as? PolicyDriversCell else { break }
            dopCell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
        case .paymentDue:
            guard let payDue = cell as? PaymentDueCell else { break }
            payDue.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
            payDue.btnTouched = {
                ApplicationContext.shared.navigator.replace("pgac://payments", context: nil, wrap: BaseNavigationController.self)
            }
        case .idCard:
            guard let detailCell = cell as? OpenDetailCell else { break }
            detailCell.lblTitle.text = NSLocalizedString("policydetails.app.idcards", comment: "")
        case .coverage:
            guard let detailCell = cell as? OpenDetailCell else { break }
            detailCell.lblTitle.text = NSLocalizedString("policydetails.app.coverage", comment: "")
        case .policy:
            guard let detailCell = cell as? OpenDetailCell else { break }
            detailCell.lblTitle.text = NSLocalizedString("policydetails.app.policy", comment: "")
        case .related:
            guard let detailCell = cell as? OpenDetailCell else { break }
            detailCell.lblTitle.text = NSLocalizedString("policydetails.app.related", comment: "")
        case .pendingPolicyAlertView:
            guard let cell = cell as? PendingPolicyAlertViewCell else { break }
            cell.dashboardResponse = ApplicationContext.shared.dashboardManager.dashboardInfo
            cell.paymentResponse = ApplicationContext.shared.paymentsManager.dueDetails
        case .esignView:
            guard let cell = cell as? EsignCell else { break }
            cell.touchedLbl = {
                ApplicationContext.shared.policyManager.getEsign(completion: { [weak self] (innerClosure) in
                    guard let sSelf = self else { return }
                    if let response = try? innerClosure() {
                        let completeUrl = URL(string: ServiceManager.shared.esignUrl + response.url)!
                        sSelf.open(url: completeUrl)
                    }
                })
            }
        case .renewPolicy:
            guard let cell = cell as? PolicyRenewCell else { break }
            cell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
        case .getQuote:
            guard let cell = cell as? GetAQuoteCell else { break }
            cell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
        case .makePayment:
            guard let cell = cell as? MakePaymentCell else { break }
            cell.paymentResponse = ApplicationContext.shared.paymentsManager.dueDetails
            cell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
            cell.buttonTouched = {
                ApplicationContext.shared.navigator.replace("pgac://payments", context: nil, wrap: BaseNavigationController.self)
            }
        case .underReview:
            guard let _ = cell as? UnderReviewAlertCell else { break }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        let cellIdentifier = cells[row]
        
        switch cellIdentifier {
        case .idCard:
            ApplicationContext.shared.navigator.replace("pgac://idcards", context: nil, wrap: BaseNavigationController.self)
        case .coverage:
            performSegue(withIdentifier: SegueMap.coverageSegue, sender: self)
            break
        case .policy:
            ApplicationContext.shared.navigator.push("pgac://policy/history", from: nil, animated: true)
        default:
            break
        }
    }
    
    // TODO: TO determine when the underreview cell needs to be showed, by means of notification
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let row = indexPath.row
        let cellIdentifier = cells[row]
        if cellIdentifier == .underReview {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let dismiss = UITableViewRowAction(style: .normal, title: "Dismiss") { action, index in
            print("dismiss button tapped")
        }
        
        dismiss.backgroundColor = UIColor.tgGreen
        return [dismiss]
    }
    
    private func open(url: URL) {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            let safariViewController = SFSafariViewController(url: url)
            rootViewController.present(safariViewController, animated: true, completion: nil)
        }
    }

}
