//
//  SignInServiceConsumer.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 11/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import AirshipKit

enum OAuthTokenType: String {
    case facebook = "facebook"
    case google = "google"
}

class SignInServiceConsumer {
    let serviceManager = ServiceManager.shared
    let decoder = SignInDecoder()
    
    typealias GetTokenClosure = (() throws -> GetTokenResponse) -> Void
    typealias ForgotPasswordClosure = (() throws -> Void) -> Void

    /// Get's details about the user's policy payment information.
    ///
    /// - Parameters:
    ///   - username: Account holder's policy numbr, username, or email.
    ///   - password: Account holder's account password in clear text
    ///   - completion: Completion handler
    func getToken(emailOrPolicy username: String, password: String, completion: @escaping GetTokenClosure) {
        let requestBody: [String: Any] = [
            "username": username,
            "password": password,
            "authenticationType": "standard",
            "deviceId": UAirship.push().channelID ?? "12345",
            "osType": "iOS"
        ]

        let request = self.serviceManager.request(type: .post, path: "/rest/auth/login", headers: nil, body: requestBody)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                let tokenData = try self.decoder.decodeGetTokenResponse(response.jsonObject)
                
                completion({ return tokenData })
            }
            catch {
                completion({ throw error })
            }
        }
    }
    
    /// Reset user's password
    ///
    /// - Parameters:
    ///   - token: Oauth token from Google/Facebook
    ///   - type: Facebook or Google auth token.
    ///   - completion: Completion handler
    func getToken(oauthToken: String, type: OAuthTokenType, completion: @escaping GetTokenClosure) {
        let requestBody: [String: Any] = [
            "username": oauthToken,
            "password": oauthToken,
            "authenticationType": type.rawValue,
            "deviceId": UAirship.push().channelID ?? "12345"
        ]
        
        let request = self.serviceManager.request(type: .post, path: "/rest/auth/login", headers: nil, body: requestBody)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                let tokenData = try self.decoder.decodeGetTokenResponse(response.jsonObject)
                
                completion({ return tokenData })
            }
            catch {
                completion({ throw error })
            }
        }
    }
    
    /// Reset user's password
    ///
    /// - Parameters:
    ///   - username: Account holder's policy numbr, username, or email.
    ///   - completion: Completion handler
    func requestPasswordReset(emailOrPolicy username: String, completion: @escaping ForgotPasswordClosure) {
        let requestBody: [String: Any] = [
            "email": username,
        ]
        
        let request = self.serviceManager.request(type: .post, path: "/rest/auth/forgotPassword", headers: nil, body: requestBody)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let _ = try innerClosure()
                completion({ })
            }
            catch {
                completion({ throw error })
            }
        }
    }
	
}
