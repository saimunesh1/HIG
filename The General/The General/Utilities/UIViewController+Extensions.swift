//
//  UIViewController+Extensions.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/21/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func alert(_ title: String, message: String) {
        let okString = NSLocalizedString("alert.ok", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okString, style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func prompt(_ title: String, message: String, ok: String, okCallback: @escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // nothing todo
        }
        
        let oKAction = UIAlertAction(title: "OK", style: .default) { action in
            okCallback()
        }

        alert.addAction(cancelAction)
        alert.addAction(oKAction)
        
        self.present(alert, animated: true)
    }

    func notYetImplemented() {
        let alert = UIAlertController(title: NSLocalizedString("alert.notyetimplemented.title", comment: ""), message: NSLocalizedString("alert.notyetimplemented.message", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.ok", comment: ""), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    var topConstraint: NSLayoutConstraint? {
        get {
            let topConstraints: Set<NSLayoutAttribute> = [.top, .topMargin]
            for constraint in self.view.constraints where topConstraints.contains(constraint.firstAttribute) {
                return constraint
            }
            return nil
        }
    }
}
