//
//  TableHeaderView.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class TableHeaderView: BaseTableViewHeaderFooterView {

    @IBOutlet var headerLabel: UILabel!
    @IBOutlet weak var leftXConstraint: NSLayoutConstraint!
    
	public func addShadow() {
		contentView.backgroundColor = .white
		contentView.layer.shadowColor = UIColor.black.cgColor
		contentView.layer.shadowOpacity = 0.05
		contentView.layer.shadowRadius = 5.0
		contentView.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
		contentView.clipsToBounds = false
	}
	
}
