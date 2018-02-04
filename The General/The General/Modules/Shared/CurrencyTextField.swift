//
//  CurrencyTextField.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class SplitPayField: CurrencyTextField {
    
    var modified: Bool {
        get {
            return userSelected
        }
    }
    
    func setValue(newValue: Decimal, animated: Bool = true) {
        guard animated else {
            super.value = newValue
            return
        }
        
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromRight
        animation.duration = 0.25
        self.layer.add(animation, forKey: "transition")
        
        super.value = newValue
    }
    
    var userSelected = false
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        self.userSelected = true
        return self
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.userSelected = true
    }
}

class CurrencyTextField: UITextField {
    var _value: Decimal = 0
    var value: Decimal {
        set {
            self._value = newValue
            self.text = NumberFormatter.currency.string(from: value as NSDecimalNumber)
        }
        get {
            return self._value
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.value = 0
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_: )), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        }
        else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        }
    }
    
    @objc func textDidChange(_ notification: Notification) {
        let cursorOffset = self.getOriginalCursorPosition()
        let sanitizedText = self.sanitizedText()
        let textFieldLength = self.text?.count
        
        if let textFieldValue = Decimal(string: sanitizedText) {
            let textFieldValue = textFieldValue / 100
            self.value = textFieldValue
        }
        else {
            let oldValue = self.value
            self.value = oldValue
        }
        
        self.setCursorOriginalPosition(cursorOffset, oldTextFieldLength: textFieldLength)
    }
}


// MARK: - Private
extension CurrencyTextField {
    fileprivate func sanitizedText() -> String {
        var textFieldString = self.text ?? ""
        textFieldString = textFieldString.replacingOccurrences(of: NumberFormatter.currency.currencySymbol, with: "")
        textFieldString = textFieldString.replacingOccurrences(of: NumberFormatter.currency.groupingSeparator, with: "")
        textFieldString = textFieldString.replacingOccurrences(of: NumberFormatter.currency.decimalSeparator, with: "")
        textFieldString = textFieldString.replacingOccurrences(of: " ", with: "")
        
        return textFieldString
    }
    
    fileprivate func getOriginalCursorPosition() -> Int {
        var cursorOffset: Int = 0
        let startPosition: UITextPosition = self.beginningOfDocument
        if let selectedTextRange = self.selectedTextRange {
            cursorOffset = self.offset(from: startPosition, to: selectedTextRange.start)
        }
        
        return cursorOffset
    }
    
    fileprivate func setCursorOriginalPosition(_ cursorOffset: Int, oldTextFieldLength: Int?) {
        let newLength = self.text?.count
        let startPosition: UITextPosition = self.beginningOfDocument
        
        if let oldTextFieldLength = oldTextFieldLength, let newLength = newLength, oldTextFieldLength > cursorOffset {
            let newOffset = newLength - oldTextFieldLength + cursorOffset
            let newCursorPosition = self.position(from: startPosition, offset: newOffset)
            
            if let newCursorPosition = newCursorPosition {
                let newSelectedRange = self.textRange(from: newCursorPosition, to: newCursorPosition)
                self.selectedTextRange = newSelectedRange
            }
        }
    }
}
