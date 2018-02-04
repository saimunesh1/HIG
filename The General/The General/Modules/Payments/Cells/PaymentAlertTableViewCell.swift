//
//  PaymentAlertTableViewCell.swift
//  The General
//
//  Created by Kevin Teman on 12/13/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

struct PaymentAlert: Equatable {
    var title: String
    var description: String
}

func ==(left: PaymentAlert, right: PaymentAlert) -> Bool {
    return left.title == right.title && left.description == right.description
}

class PaymentAlertTableViewCell: UITableViewCell {
    
    
    // MARK: - Interface
    var desiredHeight: CGFloat = 0
    
    func setup(withAlert alert: PaymentAlert) {
        
        assert(titleLabel != nil, "Outlets have not been created yet.")
        
        let kBottomBuffer: CGFloat = 20
        
        self.titleLabel.text = alert.title
        self.messageLabel.text = alert.description
        self.iconImageView.tintColor = UIColor.tgOrange
        
        self.layoutIfNeeded()
        
        self.desiredHeight = CGFloat(self.messageLabel.frame.maxY + kBottomBuffer)
    }
    
    func clear() {
        
        self.titleLabel.text = nil
        self.messageLabel.text = nil
        self.desiredHeight = 0
    }
    
    
    // MARK: - Private
    @IBOutlet fileprivate weak var iconImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var messageLabel: UILabel!
}
