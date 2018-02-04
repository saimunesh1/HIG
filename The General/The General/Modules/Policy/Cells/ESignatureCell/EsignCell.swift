//
//  EsignCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class EsignCell: UITableViewCell {
  
    @IBOutlet weak var lblEsign: UILabel!
    var touchedLbl: (() -> Void)?
    
    override func awakeFromNib() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        lblEsign.addGestureRecognizer(tap)
    }
    
    @objc private func tapped() {
        touchedLbl?()
    }
}
