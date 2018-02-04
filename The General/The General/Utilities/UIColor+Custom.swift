//
//  ThemeColors.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/9/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

struct ThemeColors {

    private struct Alphas {
        static let opaque = CGFloat(1)
        static let semiOpaque = CGFloat(0.8)
        static let semiTransparent = CGFloat(0.5)
        static let transparent = CGFloat(0.3)
    }
    
    static let appPrimaryColor =  UIColor.white.withAlphaComponent(Alphas.semiOpaque)
    static let appSecondaryColor =  UIColor.blue.withAlphaComponent(Alphas.opaque)
    static let cardColor = UIColor(red: 229.0, green: 230.0, blue: 231.0, alpha: Alphas.opaque)
    
    struct TextColors {
        static let error = ThemeColors.appSecondaryColor
        static let success = UIColor(red: 0.1303, green: 0.9915, blue: 0.0233, alpha: Alphas.opaque)
        static let selectableColor = UIColor(red: 18.0 / 255.0, green: 137.0 / 255.0, blue: 104.0 / 255.0, alpha: Alphas.opaque)
        static let titleColor = UIColor(red: 58.0 / 255.0, green: 65.0 / 255.0, blue: 73.0 / 255.0, alpha: Alphas.opaque)
        static let deleteActionColor = UIColor(red: 244.0 / 255.0, green: 35.0 / 255.0, blue: 60.0 / 255.0, alpha: Alphas.opaque)
    }
    
    struct TabBarColors {
        static let selected = UIColor.tgGreen
        static let notSelected = UIColor.tgGray
    }
    
    struct OverlayColor {
        static let semiTransparentBlack = UIColor.black.withAlphaComponent(Alphas.transparent)
        static let semiOpaque = UIColor.black.withAlphaComponent(Alphas.semiOpaque)
        static let demoOverlay = UIColor.black.withAlphaComponent(0.6)
    }
    
}

extension UIColor {
    static let tgGreen = UIColor(red: 0 / 255, green: 122 / 255, blue: 83 / 255, alpha: 1)
    static let tgOrange = UIColor(red: 253 / 255, green: 179 / 255, blue: 8 / 255, alpha: 1)
    static let tgHeaderGreen = UIColor(red: 197 / 255, green: 226 / 255, blue: 215 / 255, alpha: 1)
    static let tgLightGreen = UIColor(red: 234 / 255, green: 244 / 255, blue: 240 / 255, alpha: 1)
    static let tgGray = UIColor(red: 229 / 255, green: 230 / 255, blue: 231 / 255, alpha: 1.0)
    static let extraLightGray = UIColor(red: 220 / 255, green: 221 / 255, blue: 222 / 255, alpha: 1.0)
    static let tgTextFontColor = UIColor(red: 58 / 255, green: 65 / 255, blue: 73 / 255, alpha: 1.0)
    static let tgRed = UIColor(red: 244 / 255, green: 35 / 255, blue: 60 / 255, alpha: 1)
    static let tgYellow = UIColor(red: 255 / 255, green: 191 / 255, blue: 0 / 255, alpha: 1)
}
