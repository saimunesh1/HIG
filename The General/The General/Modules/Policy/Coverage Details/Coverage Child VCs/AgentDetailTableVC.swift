//
//  AgentDetailTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/4/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

fileprivate enum CellIdentifier: Int {
    case agentInfo
    case thirdParty
    case support
    
    var value: String {
        switch self {
        case .agentInfo: return "AgentInfoCell"
        case .thirdParty: return "AgentInfoCell"
        case .support: return "SupportCell"
        }
    }
    
    static func allObjectStrings() -> [String] {
        return [
            self.agentInfo.value,
            self.thirdParty.value,
            self.support.value
        ]
    }
}


class AgentDetailTableVC: UITableViewController, PolicyNavigatable {

    private struct Dimension {
        static let supportHeight: CGFloat = 535.0
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
        tableView.register(SectionHeader.nib, forHeaderFooterViewReuseIdentifier: SectionHeader.identifier)
    }
    
    func updateCells() {
        cells.removeAll()
        if let agentInfo = ApplicationContext.shared.policyManager.agentInfo {
            cells += [.agentInfo]
            if let _ = agentInfo.thirdPartyAddress1 {
                cells += [.thirdParty]
            }
            cells += [.support]
        }
        tableView.reloadData()
    }
}

extension AgentDetailTableVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let cellIdentifier = cells[section]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.value, for: indexPath)
        
        switch cellIdentifier {
        case .agentInfo:
            guard let agentCell = cell as? AgentInfoCell else { break }
            agentCell.agentInfo = ApplicationContext.shared.policyManager.agentInfo

        case .thirdParty:
            guard let agentCell = cell as? AgentInfoCell else { break }
            agentCell.agentInfo = ApplicationContext.shared.policyManager.agentInfo

        case .support:
            guard let supportCell = cell as? SupportCell else { break }
            createSupportViewController(inside: supportCell)
            
            return cell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cellIdentifier = cells[section]
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeader.identifier) as! SectionHeader
        switch cellIdentifier {
        case .agentInfo:
            cell.lblTitle?.text = NSLocalizedString("coverageDetails.agentInformation", comment: "Agent Information")
        case .thirdParty:
            cell.lblTitle?.text = NSLocalizedString("coverageDetails.thirdParty", comment: "Third Party Information")
        case .support:
            cell.lblTitle?.text = NSLocalizedString("coverageDetails.needHelp", comment: "Need help right now?")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AgentDetailTableVC: SupportButtonsCellDelegate {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if cells[indexPath.section] == .support {
            return Dimension.supportHeight
        }
        
        return UITableViewAutomaticDimension
    }
    
    func didTap(cell: SupportButtonCell) {
        // TODO: Implement this
        switch cell.type {
        case .helpCenter:
            break
        case .chat:
            break
        case .email:
            break
        case .callUs:
            break
        case .callBack:
            break
        }
    }
    
}
