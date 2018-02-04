//
//  BaseTableViewCell.swift
//  The General
//
//  Created by Trevor Alyn on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
		let view = UIView()
		view.backgroundColor = .white
		selectedBackgroundView = view
		selectionStyle = .none
    }

	static var nib: UINib {
		return UINib(nibName: identifier, bundle: nil)
	}
	
	static var identifier: String {
		return String(describing: self)
	}

}
