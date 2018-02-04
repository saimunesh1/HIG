//
//  SessionManager.swift
//  The General
//
//  Created by Derek Bowen on 10/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

class SessionManager {
    enum Notifications: String, NotificationName {
        case sessionStarted = "SessionManager.sessionStarted"
        case sessionEnded = "SessionManager.sessionEnded"
    }
    
    enum SessionKeys: String {
        case policyNumber = "com.pgac.policyNumber"
        case username = "com.pgac.username"
        case password = "com.pgac.password"
		case callBackPhoneNumber = "com.pgac.callBackPhoneNumber"
        case accessToken = "com.pgac.accessToken"
        case sessionExpirationTime = "com.pgac.sessionExpirationDate"
    }
    
    /// How long sessions last once user leaves the app
    static let sessionExpirationTime: TimeInterval = 15 * 60
    
    /// Starts a new session and notifications observers
    ///
    /// - Parameters:
    ///   - accessToken: TGT from login response
    ///   - policyNumber: User's policy number
    class func startSession(accessToken: String, policyNumber: String?) {
        self.accessToken = accessToken
        self.policyNumber = policyNumber
        
        NotificationCenter.default.post(name: Notifications.sessionStarted.name, object: nil)
    }
    
    /// Ends the current session and notifies observers
    class func endSession() {
        guard self.accessToken != nil else { return }
        
        self.accessToken = nil
        self.policyNumber = nil
        self.sessionExpirationDate = nil
        
        ApplicationContext.shared.dashboardManager.clearDashboardInfo()
        
        // TODO: Call logout
        
        NotificationCenter.default.post(name: Notifications.sessionEnded.name, object: nil)
    }
    
    /// Refreshes the expiration time for the current access token
    class func refreshSession() {
        let sessionExpirationDate = Date().addingTimeInterval(self.sessionExpirationTime)
        self.sessionExpirationDate = sessionExpirationDate
    }
    
    /// Returns if a session is valid or not.
    class var isSessionValid: Bool {
        // Do we have an access token?
        if self.accessToken != nil {
            // Check if the token has expired
            if let sessionExpirationDate = self.sessionExpirationDate, sessionExpirationDate < Date() {
                // End the session
                self.endSession()
                return false
            }
            return true
        }
        // No access token
        else {
            return false
        }
    }
    
    /// Policy number of logged in user
    fileprivate(set) static var policyNumber: String? {
        get {
            do {
                return try SecureKeychain.string(forKey: SessionKeys.policyNumber.rawValue)
            }
            catch {
                return nil
            }
        }
        set {
            if newValue != nil {
                try? SecureKeychain.setString(newValue!, forKey: SessionKeys.policyNumber.rawValue)
            }
            else {
                try? SecureKeychain.removeObject(forKey: SessionKeys.policyNumber.rawValue)
            }
        }
    }
    
	/// Username of logged in user
	static var username: String? {
		get {
			do {
				return try SecureKeychain.string(forKey: SessionKeys.username.rawValue)
			}
			catch {
				return nil
			}
		}
		set {
			if newValue != nil {
				try? SecureKeychain.setString(newValue!, forKey: SessionKeys.username.rawValue)
			}
			else {
				try? SecureKeychain.removeObject(forKey: SessionKeys.username.rawValue)
			}
		}
	}
    static var password: String? {
        get {
            do {
                return try SecureKeychain.string(forKey: SessionKeys.password.rawValue)
            }
            catch {
                return nil
            }
        }
        set {
            if newValue != nil {
                try? SecureKeychain.setString(newValue!, forKey: SessionKeys.password.rawValue)
            }
            else {
                try? SecureKeychain.removeObject(forKey: SessionKeys.password.rawValue)
            }
        }
    }
    
	
	/// Phone number specified for support call-back
	static var callBackPhoneNumber: String? {
		get {
			do {
				return try SecureKeychain.string(forKey: SessionKeys.callBackPhoneNumber.rawValue)
			}
			catch {
				return nil
			}
		}
		set {
			if newValue != nil {
				try? SecureKeychain.setString(newValue!, forKey: SessionKeys.callBackPhoneNumber.rawValue)
			}
			else {
				try? SecureKeychain.removeObject(forKey: SessionKeys.callBackPhoneNumber.rawValue)
			}
		}
	}
	
    /// Access token (TGT) used for authenticating in service calls
    fileprivate(set) static var accessToken: String? {
        get {
            do {
                return try SecureKeychain.string(forKey: SessionKeys.accessToken.rawValue)
            }
            catch {
                return nil
            }
        }
        set {
            if newValue != nil {
                try? SecureKeychain.setString(newValue!, forKey: SessionKeys.accessToken.rawValue)
            }
            else {
                try? SecureKeychain.removeObject(forKey: SessionKeys.accessToken.rawValue)
            }
        }
    }
    
    /// Date the access will expire
    static var sessionExpirationDate: Date? {
        get {
            do {
                guard let expirationDateString = try SecureKeychain.string(forKey: SessionKeys.sessionExpirationTime.rawValue) else { return nil}
                return ISO8601DateFormatter().date(from: expirationDateString)
            }
            catch {
                return nil
            }
        }
        set {
            if newValue != nil {
                try? SecureKeychain.setString(ISO8601DateFormatter().string(from: newValue!), forKey: SessionKeys.sessionExpirationTime.rawValue)
            }
            else {
                try? SecureKeychain.removeObject(forKey: SessionKeys.sessionExpirationTime.rawValue)
            }
        }
    }
}
