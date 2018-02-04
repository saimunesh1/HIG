//
//  PictureCameraTableViewCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class HeaderCell: BaseTableViewCell {

    @IBOutlet var titleLabel: UILabel!
	@IBOutlet weak var headerImageView: UIImageView!
	
	public var field: Field? {
		didSet {
			guard let value = field else {
				return
			}
			titleLabel.text = value.placeHolder?.initialCapped
		}
	}
	
}
