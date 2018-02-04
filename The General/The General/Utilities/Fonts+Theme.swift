//
//  FontsCollection.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

extension UIFont {
    static var headerFont: UIFont {
        return UIFont (name: "OpenSans-Regular", size: 28)!
    }
    
    static var title: UIFont {
        return UIFont (name: "OpenSans-Regular", size: 26)!
    }
    
    static var largeText: UIFont {
        return UIFont (name: "OpenSans-Regular", size: 16)!
    }
    
    static var text: UIFont {
        return UIFont (name: "OpenSans-Regular", size: 14)!
    }
    
    static var textSmall: UIFont {
        return UIFont (name: "OpenSans-Regular", size: 12)!
    }
    
    static var buttonTitle: UIFont {
        return UIFont(name: "OpenSans-Regular", size: 20)!
    }
    
    static var alert: UIFont {
        return UIFont(name: "OpenSans-Semibold", size: 14)!
    }
    
	static var link: UIFont {
		return UIFont(name: "OpenSans-Semibold", size: 16)!
	}
	
    static var boldTitle: UIFont {
        return UIFont(name: "OpenSans-Bold", size: 16)!
    }
    
    static var lightTitle: UIFont {
        return UIFont(name: "OpenSans-Light", size: 16)!
    }
}
