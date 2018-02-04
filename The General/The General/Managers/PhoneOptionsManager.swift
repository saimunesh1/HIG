//
//  PhoneOptionsManager.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/17/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

class PhoneOptionsManager {
    
    let serviceConsumer = PhoneOptionsServiceConsumer()

    typealias PhoneOptionsInfoClosure = (() throws -> Void) -> Void
    typealias UpdatePhoneOptionsInfoClosure = (() throws -> Void) -> Void

    /// Results For phone preferences screen
    private(set) var phonesInfo: PhonesResponse?

    ///  Fetches Phone information for the policy user
    ///
    /// - Parameter completion: Completion handler
    func fetchPhones(completion: @escaping PhoneOptionsInfoClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }
        
        self.serviceConsumer.fetchPhoneOptions(with: policyNumber) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.phonesInfo = response
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    ///  Updates Phone information for the policy user
    ///
    /// - Paramter body: the PhoneOptionRequest item to build the request body
    /// - Parameter completion: Completion handler
    func updatePhones(with body: [PhoneOptionsRequest], completion: @escaping UpdatePhoneOptionsInfoClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }
        
        var phoneOpts: [[String: Any]] = []
        for obj in body {
            phoneOpts.append([
                "fName": obj.fName,
                "lName": obj.lName,
                "middleInitial": obj.middleInitial,
                "driverNo": obj.driverNo,
                "phoneAreaOriginal": obj.phoneAreaOriginal,
                "phoneNumberOriginal": obj.phoneNumberOriginal,
                "phoneArea": obj.phoneArea,
                "phoneNumber": obj.phoneNumber,
                "primaryFlag": obj.primaryFlag,
                "preferenceOriginal": obj.preferenceOriginal,
                "preferenceNew": obj.preferenceNew
                ])
        }
        let requestBody: [String: Any] = [
            "phoneOptsServiceRequest": [
                "policyNumber": policyNumber,
                "phoneOpts": phoneOpts
            ]
        ]
        
        self.serviceConsumer.updatePhoneOptions(with: requestBody) { (innerClosure) in
            do {
                let _ = try innerClosure()
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

}
