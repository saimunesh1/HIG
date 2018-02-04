//
//  UINavigationController+Extensions.swift
//  The General
//
//  Created by Leif Harrison on 11/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

extension UINavigationController {

    func showNavigationBarShadow() {
        self.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.navigationBar.layer.shadowRadius = 15
        self.navigationBar.layer.shadowOpacity = 0.05
    }

    func hideNavigationBarShadow() {
        self.navigationBar.layer.shadowOpacity = 0.0
    }
    
}
