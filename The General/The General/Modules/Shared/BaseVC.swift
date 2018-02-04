//
//  BaseVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import MagicalRecord
import CoreData

class BaseVC: UIViewController {

	internal let addressRowHeight: CGFloat = 110.0
	internal let locationQuickPickRowHeight: CGFloat = 150.0
	internal let datePickerRowHeight: CGFloat = 60.0
	internal let datePickerRowHeightExpanded: CGFloat = 250.0
	internal let defaultDetailsRowHeight: CGFloat = 90.0
	internal let defaultFooterHeight: CGFloat = 90.0
	internal let defaultHeaderHeight: CGFloat = 90.0
	internal let defaultRowHeight: CGFloat = 60.0
	internal let defaultSegmentViewRowHeight: CGFloat = 150.0
	internal let keyboardHeight: CGFloat = 260.0
	internal let photoCellRowHeight: CGFloat = 175.0
	internal let pickerCollapsedRowHeight: CGFloat = 80.0
	internal let pickerExpandedRowHeight: CGFloat = 250.0
    internal let severeDamageCellHeight: CGFloat = 246.0
    internal let expandedPhotoCellHeight: CGFloat = 120.0

    let formValidator = FormErrorValidator()

	override func viewDidLoad() {
		super.viewDidLoad()
        
        formValidator.styleTransformers(success: { (validationRule) -> Void in
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
        }, error:{ (validationError) -> Void in
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
        })
        
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender: )), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender: )), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	@objc func keyboardWillShow(sender: NSNotification) {
	}
	
	@objc func keyboardWillHide(sender: NSNotification) {
	}
    
    @IBAction func goBack(segue: UIStoryboardSegue) {
        
        goBack()
    }

    @IBAction func goBack() {
        
        if let navigationController = self.navigationController, navigationController.viewControllers.count > 1, self.navigationController?.topViewController === self || self.presentingViewController == nil {
            
            self.navigationController?.popViewController(animated: true)
            
        } else {
            
            dismiss(animated: true, completion: nil)
        }
    }

	func showLocationDisabledAlert() {
		let alertController = UIAlertController(title: "", message: NSLocalizedString("alert.location.message", comment: ""), preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: NSLocalizedString( "alert.cancel", comment: ""), style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		let openAction = UIAlertAction(title: NSLocalizedString("alert.settings", comment: ""), style: .default) { (action) in
			if let url = URL(string: UIApplicationOpenSettingsURLString) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
		alertController.addAction(openAction)
		self.present(alertController, animated: true, completion: nil)
	}
}
