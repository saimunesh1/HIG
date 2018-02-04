//
//  LocationCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ThreeLocationCell: BaseTableViewCell {
	
	@IBOutlet weak var accidentLocationButton: BorderUIButton!
	@IBOutlet weak var accidentLocationLabel: UILabel!
	@IBOutlet weak var myLocationButton: BorderUIButton!
	@IBOutlet weak var myLocationLabel: UILabel!
	@IBOutlet weak var homeButton: BorderUIButton!
	@IBOutlet weak var homeLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var accidentLocationImageView: UIImageView!
	
	var delegate: ThreeLocationCellDelegate?
	var field: Field?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		accidentLocationImageView.tintColor = .tgGreen
		accidentLocationLabel.text = NSLocalizedString("location.attheaccidentlocation", comment: "At the accident location")
		myLocationLabel.text = NSLocalizedString("location.atmylocation", comment: "At my location")
		homeLabel.text = NSLocalizedString("location.atmyresidence", comment: "At my residence")
		myLocationButton.isEnabled = NetworkReachability.isConnectedToNetwork()
	}
	
	private func clearButtons() {
		accidentLocationButton.isSelected = false
		myLocationButton.isSelected = false
		homeButton.isSelected = false
	}
	
	@IBAction func didTouchOnAccidentLocation(_ sender: Any) {
		clearButtons()
		accidentLocationButton.isSelected = true
		delegate?.didTouchOnAccidentLocation()
	}
	
	@IBAction func didTouchOnMyLocation(_ sender: Any) {
		clearButtons()
		myLocationButton.isSelected = true
		delegate?.didTouchOnMyLocation()
	}
	
	@IBAction func didTouchOnHome(_ sender: Any) {
		clearButtons()
		homeButton.isSelected =  true
		delegate?.didTouchOnHome()
	}
	
}
