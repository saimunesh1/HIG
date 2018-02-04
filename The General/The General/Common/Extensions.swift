//
//  Extensions.swift
//  The General
//
//  Created by Moore, Michael (US - New York) on 10/7/17.
//  Copyright © 2017 Deloitte Digital. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {

    func addRightBorder(color: UIColor, thickness: CGFloat, inset: CGFloat) {

        let border = CALayer()

        border.frame = CGRect(x: frame.width, y: inset + thickness, width: thickness, height: frame.height - (inset * 2) - (thickness * 2))

        border.backgroundColor = color.cgColor

        self.addSublayer(border)
    }
    
    func addRightBorder(color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        
        border.backgroundColor = color.cgColor
        
        self.addSublayer(border)
    }

    func addTopBorder(color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)

        border.backgroundColor = color.cgColor

        self.addSublayer(border)
    }

    func addBottomBorder(color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)

        border.backgroundColor = color.cgColor

        self.addSublayer(border)
    }
    
    func addLeftBorder(color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        
        border.backgroundColor = color.cgColor
        
        self.addSublayer(border)
    }
}

extension String {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
	
	var initialCapped: String {
		return self.lowercased().capitalized
	}
}

extension Bool {
	var yesNoString: String {
		return self == true ? NSLocalizedString("alert.yes", comment: "Yes") : NSLocalizedString("alert.no", comment: "No")
	}
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(vc: UIViewController) -> UIViewController {
        switch(vc) {
        case is UINavigationController:
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom( vc: navigationController.visibleViewController!)
        case is UITabBarController:
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)
        default:
            if let presentedViewController = vc.presentedViewController {
                if let innerVC = presentedViewController.presentedViewController {
                    return UIWindow.getVisibleViewControllerFrom(vc: innerVC)
                }
                else { return vc }
            }
            return vc
        }
    }
}

extension Range where Bound == String.Index {
    var nsRange: NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}

extension NSMutableAttributedString{
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        }
    }
    
    public func setAsLink(textToFind: String, inText: String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSAttributedStringKey.link, value: inText, range: foundRange)
            
            return true
        }
        
        return false
    }
}

extension String {
    
    func capitalizedFirst() -> String {
        let first = self[self.startIndex ..< self.index(startIndex, offsetBy: 1)]
        let rest = self[self.index(startIndex, offsetBy: 1) ..< self.endIndex]
        return first.uppercased() + rest.lowercased()
    }
    
    func capitalized(with: Locale?) -> String {
        let first = self[self.startIndex ..< self.index(startIndex, offsetBy: 1)]
        let rest = self[self.index(startIndex, offsetBy: 1) ..< self.endIndex]
        return first.uppercased(with: with) + rest.lowercased(with: with)
    }
    
    func replaceEachCharacterWithXSaveLast4Digits() -> String {
        if self.count <= 4 { return self }
        let last4Digits = String(self.suffix(4))
        let exes = String(String(self.prefix(upTo: self.index(self.endIndex, offsetBy: -4))).map { (_) -> Character in
            Character.init("X")
        })
        let exesPlusLast4 = exes + last4Digits
        return exesPlusLast4
    }
}
