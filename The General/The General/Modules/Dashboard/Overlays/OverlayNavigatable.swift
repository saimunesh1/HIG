//
//  OverlayNavigatable.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/8/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

protocol OverlayNavigatable {
    func showHelpCenterOverlayIfNecessary()
    func showAccessCardOverlayIfNecessary()
}

extension OverlayNavigatable where Self: UIViewController {

	func showHelpCenterOverlayIfNecessary() {
        showOverlayIfNecessary(storyboardId: "HelpCenterOverlayViewController")
    }

	func showAccessCardOverlayIfNecessary() {
		showOverlayIfNecessary(storyboardId: "AccessCardOverlayViewController")
	}
	
	func showPassengerOverlayIfNecessary() {
		showOverlayIfNecessary(storyboardId: "PassengerOverlayViewController")
	}
	
    private func showOverlayIfNecessary(storyboardId: String) {
        let defaultsKey = "\(storyboardId)-displayed"
        
        // show overlay one time
        if !UserDefaults.standard.bool(forKey: defaultsKey) {
            let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
            
            if let vc = storyboard.instantiateViewController(withIdentifier: storyboardId) as? UIViewController & Overlayable {
                vc.modalPresentationStyle = .overFullScreen
                
                vc.onDidTouchAnywhere = {
                    vc.dismiss(animated: false, completion: nil)
                }
                
                self.present(vc, animated: false, completion: nil)
            }

            UserDefaults.standard.set(true, forKey: defaultsKey)
        }
    }
	
}
