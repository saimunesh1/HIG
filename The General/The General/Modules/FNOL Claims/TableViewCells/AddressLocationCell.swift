//
//  AddressLocationCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AddressLocationCell: BaseTableViewCell {

    @IBOutlet var homeButton: BorderUIButton!
    @IBOutlet var locationBtn: BorderUIButton!
    
    var delegate: AddressLocationDelegate?
    var item: Field?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		locationBtn.isEnabled = NetworkReachability.isConnectedToNetwork()
	}
    
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
