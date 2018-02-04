//
//  UnderReviewAlertCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 17/01/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class UnderReviewAlertCell: UITableViewCell {

    @IBOutlet weak var lblWarning: UILabel!
    @IBOutlet weak var alertImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        alertImage.tintColor = .tgYellow
    }    
}
