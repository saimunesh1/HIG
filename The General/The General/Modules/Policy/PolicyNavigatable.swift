//
//  PolicyNavigatable.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/8/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

protocol PolicyNavigatable: class {
    func pushModifyPolicyOnNavigationController()
}

extension PolicyNavigatable where Self: UIViewController {
    func pushModifyPolicyOnNavigationController() {
        let storyboard = UIStoryboard(name: "Policy-Modify", bundle: nil)
        
        if let vc = storyboard.instantiateInitialViewController() as? ModifyPolicyViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func createSupportViewController(inside cell: SupportCell) {
        let sb = UIStoryboard(name: "Support", bundle: nil)
        
        if let vc = sb.instantiateViewController(withIdentifier: "SupportVC") as? SupportVC {
            cell.supportViewController = vc
            
            vc.viewMode = .child
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(vc.view)
            
            vc.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            vc.view.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
            vc.view.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
            vc.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        }
    }
}
