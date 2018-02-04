//
//  UIView+Custom.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/24/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import Foundation

class TapGestureRecognizer: UITapGestureRecognizer {
    
    let identifier: String
    
    private override init(target: Any?, action: Selector?) {
        self.identifier = ""
        super.init(target: target, action: action)
    }
    
    init(target: Any?, action: Selector?, identifier: String) {
        self.identifier = identifier
        super.init(target: target, action: action)
    }
    
    static func ==(left: TapGestureRecognizer, right: TapGestureRecognizer) -> Bool {
        return left.identifier == right.identifier
    }
}

extension UIView {
    
    private var hideKeyboardWhenTappedGestureRecognizerIdentifier: String {
        return "hideKeyboardWhenTapped"
    }
    
    private var hideKeyboardWhenTappedGestureRecognizer: UITapGestureRecognizer? {
        
        let hideKeyboardGesture = TapGestureRecognizer(target: self, action: #selector(UIView.hideKeyboard), identifier: hideKeyboardWhenTappedGestureRecognizerIdentifier)
        
        if let gestureRecognizers = self.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                if let tapGestureRecognizer = gestureRecognizer as? TapGestureRecognizer, tapGestureRecognizer == hideKeyboardGesture, tapGestureRecognizer == hideKeyboardGesture {
                    return tapGestureRecognizer
                }
            }
        }
        return nil
    }
    
    @objc private func hideKeyboard() {
        endEditing(true)
    }
    
    @IBInspectable
    var hideKeyboardWhenTapped: Bool {
        
        set {
            let hideKeyboardGesture = TapGestureRecognizer(target: self, action: #selector(UIView.hideKeyboard), identifier: hideKeyboardWhenTappedGestureRecognizerIdentifier)
            
            if let hideKeyboardWhenTappedGestureRecognizer = self.hideKeyboardWhenTappedGestureRecognizer {
                removeGestureRecognizer(hideKeyboardWhenTappedGestureRecognizer)
                if gestureRecognizers?.count == 0 {
                    gestureRecognizers = nil
                }
            }
            
            if newValue {
                addGestureRecognizer(hideKeyboardGesture)
            }
        }
        
        get {
            return hideKeyboardWhenTappedGestureRecognizer == nil ? false : true
        }
    }
}
