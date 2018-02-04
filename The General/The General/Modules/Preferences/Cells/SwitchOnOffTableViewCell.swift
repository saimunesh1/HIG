//
//  SwitchOnOffTableViewCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/20/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class SwitchOnOffTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var switchOnOff: OnOffSegmentControl!
    var valueChange: ((Bool)->Void)?
    
    @IBAction func segmentTouched(_ sender: OnOffSegmentControl) {
        valueChange?(sender.value)
    }
}
