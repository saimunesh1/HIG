//
//  PhotosCollectionViewCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/22/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PhotosCollectionViewCell: OnboardingCollectionViewCell {

	@IBOutlet var cardButton: UIButton!
    
    var actionDelegate: FNOLOnboardingDelegate?
	
    @IBAction func onTouchButton(_ sender: Any) {
        actionDelegate?.didTouchOnTakePictures()
    }
    
}
