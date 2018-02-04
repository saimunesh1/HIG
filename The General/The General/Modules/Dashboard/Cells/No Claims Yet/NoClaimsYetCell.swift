//
//  NoClaimsYetCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class NoClaimsYetCell: UITableViewCell {
    var onCreateClaimButtonTouched: (() -> ())?
    
    @IBAction func didTouchCreateClaimButton(_ sender: UIButton) {
        onCreateClaimButtonTouched?()
    }
}
