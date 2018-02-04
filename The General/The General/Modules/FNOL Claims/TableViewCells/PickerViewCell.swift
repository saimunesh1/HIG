//
//  PickerViewCell.swift
//  The General
//
//  Created by Derek Bowen on 10/19/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PickerViewCell: BaseTableViewCell {
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        checkImageView.tintColor = .tgGreen
    }
}
