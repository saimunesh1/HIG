//
//  ProfileInfoTableViewCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/20/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ProfileInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }
    
}
