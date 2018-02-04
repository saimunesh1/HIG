//
//  PreferencesServicesConsumer.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/01/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

class PreferencesServicesConsumer {
    let serviceManager = ServiceManager.shared
    
    typealias GetPreferenceDetailClosure = (() throws -> PreferencesResponse) -> Void
    typealias UpdatePreferenceClosure = (() throws -> UpdateResponse) -> Void
 
    
    /// Gets a summary of App Preference of policy holder for mobile device to display on the Preference screen
    ///
    /// - Parameters:
    ///   - deviceId: Retrieve from UA
    ///   - completion: Completion handler, returns PreferencesResponse
    func fetchPreferences(with deviceId: String, completion: @escaping GetPreferenceDetailClosure) {
        
        let request = self.serviceManager.request(type: .post, path: "/rest/preferences/fetchPreferences", headers: nil, body: ["deviceId": deviceId])
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode(PreferencesResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }
    
    
    /// Updates the preferences based on deviceID
    ///
    /// - Parameters:
    ///   - deviceId: Retrieved from UA
    ///   - preferenceInformation: Preferences that need to be updated
    ///   - completion: UpdatePreferencesResponse
    func updatePreferences(with deviceId: String, info: [String: Any], completion: @escaping UpdatePreferenceClosure) {
        
        let requestBody: [String: Any] = [
            "deviceId": deviceId,
            "data": info
        ]
        let request = self.serviceManager.request(type: .post, path: "/rest/preferences/updatePreference", headers: nil, body: requestBody)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject as? [String: Any] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
                let responseModel = try JSONDecoder.shared.decode(UpdateResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }
    
}
