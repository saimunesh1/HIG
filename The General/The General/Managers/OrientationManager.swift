//
//  OrientationManager.swift
//  The General
//
//  Created by Hopkinson, Todd (US - Denver) on 1/16/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

class OrientationManager {
    
    static let shared = OrientationManager()
    private var defaultOrientationLock = UIInterfaceOrientationMask.portrait
    
    private var idCardsLandscapeVC: IDCardsLandscapeVC?
    private var isIDCardPresented: Bool {
        if idCardsLandscapeVC != nil { return true }
        return false
    }
    
    /// informs the application delegate (or whoever else cares) orientation to use at the given time.
    public private(set) var orientationLock = UIInterfaceOrientationMask.portrait
    
    init() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(detectOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    /// Locks the app's device orientaiton to the orientation parameter. Intended to be called for special circumstances needing to change app's screen orientation, i.e., ID card landscape mode. Call counterpart restoreOrientation() to clean up special orientation circumstance and return the app to default orientation.
    ///
    /// - Parameters:
    ///   - orientation: the orientation to set for a given view controller
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        self.orientationLock = orientation
    }
    
    /// Restores the app to its the expected default orientation
    func restoreOrientation() {
        self.orientationLock = defaultOrientationLock
    }
    
    @objc func detectOrientation(notification: Notification) {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            self.presentIDCardOverlay(orientation: .landscapeRight)
        case .landscapeRight:
            self.presentIDCardOverlay(orientation: .landscapeLeft)
        case .portrait:
            self.dismissIDCardOverlay()
        default:
            return
        }
    }
    
    
    // MARK - IDCards Landscape Support
    func presentIDCardOverlay(orientation: UIDeviceOrientation) {
        
        if !SessionManager.isSessionValid && !IDCardManager.isCardIDInfoCached { return } // don't allow rotation to launch id cards if never seen before AND logged out
        
        if let window = UIApplication.shared.keyWindow, let topVC = window.visibleViewController() {
            
            let interfaceOrientationMask = (orientation == UIDeviceOrientation.landscapeLeft) ? UIInterfaceOrientationMask.landscapeLeft : UIInterfaceOrientationMask.landscapeRight
            self.lockOrientation(interfaceOrientationMask)
            if isIDCardPresented {
                return
            }
            
            guard let vc = UIStoryboard(name: "IDCards", bundle: nil).instantiateViewController(withIdentifier: "IDCardsLandscapeVC") as? IDCardsLandscapeVC else { return }
            idCardsLandscapeVC = vc
            topVC.present(vc, animated: true, completion: nil)
        }
    }
    
    func dismissIDCardOverlay() {
        if let overlay = idCardsLandscapeVC {
            self.restoreOrientation()
            overlay.dismiss(animated: true, completion: nil)
            idCardsLandscapeVC = nil
        }
    }
}
