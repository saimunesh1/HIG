//
//  SignInManager.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

enum SignInError:Error {
    case noCredentialsFound
}

class SignInManager {
    
    /**
     Returns a URL for a user to create an account
     */
	func createAccountUrlString() -> String? {
		if let urlSubstring = ApplicationContext.shared.configurationManager.configuration?.registration?.registrationUrl {
			return "\(ServiceManager.shared.webContentBaseURL)\(urlSubstring)"
		}
		return nil
	}
    
    /**
     Sign in can be called with OR without username and password. If no username and password are passed in, then username and password will be taken from keychain (stored at last login).
     - Parameters:
        - username: Optional username, if none is provided, will be taken from keychain.
        - password: Optional password, if none is provided, will be taken from keychain.
        - success: Called on success.
        - failure: Called on failure with parameter of error message which should be displayed to user.
     */
    func signIn(username: String? = nil, password: String? = nil, success: @escaping () -> (), failure: @escaping (_ errorMessage: String)->()) throws {
        
        var usernameToUse: String! = username
        var passwordToUse: String! = password
        
        if usernameToUse == nil {
            usernameToUse = SessionManager.username
        }
        
        if passwordToUse == nil {
            passwordToUse = SessionManager.password
        }
        
        guard usernameToUse != nil && passwordToUse != nil else {
            throw SignInError.noCredentialsFound
        }
        
        self.signInService.getToken(emailOrPolicy: usernameToUse, password: passwordToUse) { innerClosure in
            
            do {
                let token = try innerClosure()
                let policyNumber = token.policyNumber
                
                SessionManager.startSession(accessToken: token.tgt, policyNumber: policyNumber)
                
                SessionManager.username = usernameToUse
                SessionManager.password = passwordToUse
                
                success()
            }
            catch ServiceErrorType.unsuccessful {
                failure(NSLocalizedString("Policy number, email, or password do not match", comment: ""))
            }
            catch let error {
                failure(error.localizedDescription)
            }
        }
    }
    
    private lazy var signInService = SignInServiceConsumer()
}
