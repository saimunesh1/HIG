//
//  LocationTitleTableViewCell.swift
//  The General
//
//  Created by Michael Moore on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class LocationTitleTableViewCell: BaseTableViewCell {

    @IBOutlet var homeButton: BorderUIButton!
    @IBOutlet var locationBtn: BorderUIButton!
    @IBOutlet var titleLabel: UILabel!
    
    var delegate: AddressLocationDelegate?
    var item: Field?
    
    @IBAction func didTouchOnLocation(_ sender: Any) {
        self.locationBtn.isSelected = true
        self.homeButton.isSelected =  false
        delegate?.didTouchOnLocation()
    }
    
    @IBAction func didTouchOnHome(_ sender: Any) {
        self.homeButton.isSelected =  true
        self.locationBtn.isSelected = false
        delegate?.didTouchOnHome()
    }

}
