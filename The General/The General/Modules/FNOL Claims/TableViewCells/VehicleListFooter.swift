//
//  VehicleListFooter.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class VehicleListFooter: UITableViewHeaderFooterView, UIGestureRecognizerDelegate {

    var delegate: VehicleListFooterDelegate?
    
       override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(tap: )))
        gestureRecognizer.delegate = self
        self.contentView.addGestureRecognizer(gestureRecognizer)
    }
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @objc func handleTap(tap: UITapGestureRecognizer) {
        delegate?.didTouchonOtherVehicle()
    }
    static var identifier: String {
        return String(describing: self)
    }
}
