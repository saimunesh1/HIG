//
//  OnboardingCollectionView.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/21/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

enum OnboardingCardType {
	case safetyFirst
	case getInfo
	case capturePhoto
	case processClaim
	case trackProgress
	case paymentOptions
	case insuranceVerification
	case claimsAndPolicy
	case helpCenter
	case unknown
}

struct OnboardingCard {
	let cellID: String!
	let type: OnboardingCardType
}

class OnboardingCollectionView: UICollectionView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5;
        self.layer.shadowOffset =  CGSize(width: -15, height: 20)
        self.layer.shadowRadius = 15;
        self.layer.shadowOpacity = 0.1;
        self.clipsToBounds = false
        
    }
    
}
