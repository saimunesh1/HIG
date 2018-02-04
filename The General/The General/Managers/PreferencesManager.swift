//
//  PreferencesManager.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import AirshipKit

class PreferencesManager {
    
    let serviceConsumer = PreferencesServicesConsumer()
    
    typealias UpdatePreferenceInfoClosure = (() throws -> Void) -> Void
    typealias UpdatedPreferenceClosure = (() throws -> UpdateResponse) -> Void

    /// Results For preference screen
    private(set) var preferenceInfo: PreferencesResponse?
    
    
    ///  Preference Info of App
    ///
    /// - Parameter completion: Completion handler
    func fetchPreferences(completion: @escaping UpdatePreferenceInfoClosure) {

        // Default value for simulator device ID
        let deviceId = UAirship.push().channelID ?? "12345"
        
        self.serviceConsumer.fetchPreferences(with: deviceId) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.preferenceInfo = response
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }
    
    /// Updates Preferences based on DeviceID
    ///
    /// - Parameters:
    ///   - preferenceInformations: Preference need to be updated
    ///   - completion: UpdatePreferencesResponse
    func updatePreferences(with preferenceInfo: [String: Any], completion: @escaping UpdatedPreferenceClosure) {
    
        // Default value for simulator device ID
        let deviceId = UAirship.push().channelID ?? "12345"

        self.serviceConsumer.updatePreferences(with: deviceId, info: preferenceInfo) { (innerClosure) in
            do {
                let response = try innerClosure()
                completion({ return response })
            }
            catch {
                completion({ throw error })
            }
        }
    }
        
    // App Preferences
    static var allowIDwhenLoggedOut: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "allowIDwhenLoggedOut")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "allowIDwhenLoggedOut")
        }
    }
    
    static var loggedInWithFb: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "loggedInWithFb")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "loggedInWithFb")
        }
    }
    
    static var loggedInWithGoogle: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "loggedInWithGoogle")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "loggedInWithGoogle")
        }
    }

}
