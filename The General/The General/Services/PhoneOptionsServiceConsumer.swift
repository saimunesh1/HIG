//
//  PhoneOptionsServiceConsumer.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/17/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

class PhoneOptionsServiceConsumer {
    
    let serviceManager = ServiceManager.shared

    typealias GetPhoneOptionsClosure = (() throws -> PhonesResponse) -> Void
    typealias UpdatePhoneOptionsClosure = (() throws -> Void) -> Void

    /// Gets phone options available for the policy user
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number of logged in user
    ///   - completion: Completion handler, returns PhonesResponse
    func fetchPhoneOptions(with policyNumber: String, completion: @escaping GetPhoneOptionsClosure) {
        
        let request = self.serviceManager.request(type: .get, path: "/rest/phoneOptsService/getPhoneOpts/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode(PhonesResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }

    
    /// Gets a phone options available for the policy user
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number of logged in user
    ///   - completion: Completion handler, returns PreferencesResponse
    func updatePhoneOptions(with body: [String: Any], completion: @escaping UpdatePhoneOptionsClosure) {
        
        let request = self.serviceManager.request(type: .post, path: "/rest/phoneOptsService/putPhoneOpts", headers: nil, body: body)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                _ = try innerClosure()
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

}
