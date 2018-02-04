//
//  NewClaimCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/15/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class NewClaimCell: RenderNotifyingTableViewCell {
    var onDidTouchNewClaimButton: (() -> ())?

    @IBAction func didTouchNewClaimButton(_ sender: UIButton) {
        onDidTouchNewClaimButton?()
    }
}
