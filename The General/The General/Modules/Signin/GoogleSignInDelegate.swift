//
//  GoogleSignInDelegate.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 12/5/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import GoogleSignIn

class GoogleSignInDelegate: NSObject, GIDSignInDelegate {
    typealias GoogleSignInClosure = (() throws -> GIDGoogleUser) -> Void
    static let sharedDelegate = GoogleSignInDelegate()

    private static var googleSignInCompletion: GoogleSignInClosure?

//MARK - OnSignIn completion handler
    static func onSignIn(_ completion: @escaping GoogleSignInClosure) {
        googleSignInCompletion = completion
    }
    
    private static func onGoogleSignInComplete(_ user: GIDGoogleUser?, error: Error?) {
        if let completion = self.googleSignInCompletion {
            if user != nil {
                completion({ return user! })
            }
                
            else if error != nil {
                completion({ throw error! })
            }
        }
    }

//MARK - GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            GoogleSignInDelegate.onGoogleSignInComplete(nil, error: error)
        } else {
            GoogleSignInDelegate.onGoogleSignInComplete(user, error: nil)
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        GoogleSignInDelegate.onGoogleSignInComplete(nil, error: nil)
    }

    
}
