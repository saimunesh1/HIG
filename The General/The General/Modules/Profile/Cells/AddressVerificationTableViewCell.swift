//
//  AddressVerificationTableViewCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 29/12/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AddressVerificationTableViewCell: UITableViewCell {
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var imgViewSelection: UIImageView!
    
    internal func showSelection(_ option: Bool) {
        self.imgViewSelection.isHidden = !option
    }
}
