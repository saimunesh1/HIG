//
//  MyVehicleRowCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class MyVehicleRowCell: BaseTableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueField: UITextField!
    @IBOutlet var errorLabel: UILabel!

    var item: Field? {
        didSet {
            guard let value = item else { return }
            self.titleLabel?.text = value.label
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
		if self.accessoryType != .none {
			var imageView: UIImageView
			imageView  = UIImageView(frame:CGRect(x:10, y:5, width:10, height:10))
			imageView.image = #imageLiteral(resourceName: "arrow")
			self.accessoryView = imageView
		}
	}
	
}
