//
//  ModifyPolicyViewController.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/8/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class ModifyPolicyViewController: BaseVC, PolicyNavigatable {
    
    private struct Dimension {
        static let supportHeight: CGFloat = 535.0
    }

    private struct CellIdentifier {
        static let headerCell = "HeaderCell"
        static let supportCell = "SupportCell"
    }

    @IBOutlet weak var tableView: UITableView!
}

extension ModifyPolicyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.headerCell, for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.supportCell, for: indexPath) as! SupportCell
            createSupportViewController(inside: cell)
            
            return cell
        }
    }
}

extension ModifyPolicyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            // header
            return UITableViewAutomaticDimension
        } else {
            // support
            return Dimension.supportHeight
        }
    }
}
