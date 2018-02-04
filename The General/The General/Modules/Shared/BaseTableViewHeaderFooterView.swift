//
//  BaseTableViewHeaderFooterView.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class BaseTableViewHeaderFooterView: UITableViewHeaderFooterView {

	static var nib: UINib {
		return UINib(nibName: identifier, bundle: nil)
	}
	
	static var identifier: String {
		return String(describing: self)
	}

}
