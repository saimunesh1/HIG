//
//  SafetyCollectionViewCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/21/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class SafetyCollectionViewCell: OnboardingCollectionViewCell {

    @IBOutlet var cardButton: UIButton!
    
    var actionDelegate: FNOLOnboardingDelegate?

	@IBAction func onTouchButton(_ sender: Any) {
     actionDelegate?.didTouchOnEmergencyBtn()
    }

}
