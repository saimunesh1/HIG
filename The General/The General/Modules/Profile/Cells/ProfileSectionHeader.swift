//
//  ProfileSectionHeader.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/16/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class ProfileSectionHeader: BaseTableViewHeaderFooterView {

    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    var editTouched: (()-> Void)?
    
    @IBAction func editButtonTouched(_ sender: UIButton) {
        editTouched?()
    }
}
