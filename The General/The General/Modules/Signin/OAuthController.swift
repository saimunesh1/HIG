//
//  OAuthController.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 12/5/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class OAuthController: NSObject, GIDSignInUIDelegate {
    typealias OAuthSignInClosure = (Bool) -> ()
    
    let parent: UIViewController!
    let signInService = SignInServiceConsumer()

    init(parentViewController: UIViewController) {
        self.parent = parentViewController
        super.init()
    }

    var oauthEnabled: Bool {
        get {
            return SettingsManager.firstLaunchCompleted
        }
    }
    
    func facebookSignIn(completion: @escaping OAuthSignInClosure) {
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self.parent) { [weak self] (result, error) -> Void in
            guard let weakself = self else {
                return
            }

            if error != nil {
                completion(false)
            }
            else if (result?.isCancelled)! {
                completion(false)
            }
            else {
                let token = FBSDKAccessToken.current().tokenString ?? ""
                weakself.signIn(token: token, type: OAuthTokenType.facebook, completion: completion)
            }
        }
    }
    
    func googleSignIn(completion: @escaping OAuthSignInClosure) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        GoogleSignInDelegate.onSignIn() { [weak self] innerClosure in
            guard let weakself = self else {
                return
            }
            
            do {
                let user = try innerClosure()
                let token = user.authentication.accessToken ?? ""
                weakself.signIn(token: token, type: OAuthTokenType.google, completion: completion)
            } catch let error {
                weakself.parent.alert("Oops!", message: error.localizedDescription)
            }
        }

    }
    
    private func signIn(token: String, type: OAuthTokenType, completion: @escaping OAuthSignInClosure) {
        signInService.getToken(oauthToken: token, type: type) {[weak self] (innerClosure) in
            guard let weakSelf = self else { return }
            
            do {
                let token = try innerClosure()
                
                SessionManager.startSession(accessToken: token.tgt, policyNumber: token.policyNumber)
                completion(true)
            }
            catch ServiceErrorType.unsuccessful {
                let badLoginError = NSLocalizedString("No linked account found", comment: "")
                weakSelf.parent.alert("Oops!", message: badLoginError)
            }

            catch let error {
                weakSelf.parent.alert("Oops!", message: error.localizedDescription)
            }
        }
    }
    
// MARK - GIDSignInUIDelegate
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.parent.present(viewController, animated: true, completion: nil)
    }
    
}
