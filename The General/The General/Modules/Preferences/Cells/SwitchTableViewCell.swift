//
//  SwitchTableViewCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var switchYesorNo: YesNoSegmentControl!
    var valueChange: ((Bool)->Void)?
    
    @IBAction func segmentTouched(_ sender: YesNoSegmentControl) {
        valueChange?(sender.value)
    }
}
