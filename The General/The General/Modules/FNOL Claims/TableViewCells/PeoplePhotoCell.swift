//
//  PeoplePhotoCell.swift
//  The General
//
//  Created by Trevor Alyn on 10/31/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PeoplePhotoCell: UITableViewCell {
	
	@IBOutlet weak var pictureImageView: UIImageView!
	@IBOutlet weak var leftLabel: UILabel!
	@IBOutlet weak var sizeLabel: UILabel!
	
	var picture: UIImage? {
		didSet {
			pictureImageView.image = picture
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	static var nib: UINib {
		return UINib(nibName: identifier, bundle: nil)
	}
	
	static var identifier: String {
		return String(describing: self)
	}
	
}
