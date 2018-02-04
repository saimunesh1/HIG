//
//  ClaimNavigatable.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/16/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

protocol ClaimNavigatable: class {
    func askToSubmitClaim(claim: FNOLClaim)
    func saveForLater()
    func submit(claim: FNOLClaim)
}

extension ClaimNavigatable where Self: UIViewController {

    func askToSubmitClaim(claim: FNOLClaim) {
        claim.status = ClaimStatus.claimSaved.rawValue
        let networkConnectionType = NetworkReachability.networkConnectionType()
        switch networkConnectionType {
        case .reachableViaWiFi:
            submit(claim: claim)
        case .reachableViaWWAN:
            let megabytes = ApplicationContext.shared.fnolClaimsManager.activeClaim!.sizeOfImages
            let message = NSLocalizedString("claims.dataplanwarning.message", comment: "You are about to send X of data over the cellular connection. You can save the claim and send it later over Wi-Fi.").replacingOccurrences(of: "|number|", with: "\(megabytes)")
            let alert = UIAlertController(title: NSLocalizedString("claims.dataplanwarning", comment: "Data plan warning"), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("claims.dataplanwarning.saveforlater", comment: "Save for later"), style: .default, handler: { [weak self] action in
                self?.saveForLater()
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("claims.dataplanwarning.send", comment: "Send"), style: .default, handler: { [weak self] action in
                self?.submit(claim: claim)
            }))
            present(alert, animated: true, completion: nil)
        case .notReachable:
            let alert = UIAlertController(title: NSLocalizedString("claims.nointernet", comment: "No internet connection"), message: NSLocalizedString("claims.nointernet.message", comment: "Submit your claim when you have a cellular or Wi-Fi connection."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert.ok", comment: "OK"), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    func saveForLater() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    func submit(claim: FNOLClaim) {
        LoadingView.show(inView: self.view, type: .hud, animated: true)
        ApplicationContext.shared.fnolClaimsManager.submitClaim(claim, progress: nil) { [weak self] (innerClosure) in
            guard let weakSelf = self else { return }
            LoadingView.hide(inView: weakSelf.view, animated: true)
            
            do {
                try innerClosure()
                claim.status = ClaimStatus.claimSubmitted.rawValue
                
                // TODO: Get the claim ID from the response and assign it to the claim so we can link it to established
                // claims coming back from the server
                
                self?.navigationController?.popToRootViewController(animated: true)
                
                // Handles removing the top-bar when user navigates back
                if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
                    self?.supplementalNavigationController?.removeSupplementalView(topBarView, animated: false)
                }
            }
            catch {
                let alert = UIAlertController(title: NSLocalizedString("error.unknown.title", comment: ""), message: NSLocalizedString("error.unknown.message", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("error.unknown.actionTitle", comment: ""), style: .default, handler: nil))
                weakSelf.present(alert, animated: true, completion: nil)
            }
        }
    }
}
