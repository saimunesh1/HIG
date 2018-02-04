//
//  ProfileManager.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/16/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

class ProfileManager {
    
    let serviceConsumer = ProfileServiceConsumer()

    typealias ProfileInfoClosure = (() throws -> Void) -> Void
    typealias UpdateEmailInfoClosure = (() throws -> Void) -> Void
    typealias AddressInfoClosure = (() throws -> Void) -> Void
    typealias SearchAddressInfoClosure = (() throws -> SearchAddressResponse) -> Void
    typealias UpdateAddressClosure = (() throws -> UpdateResponse) -> Void
    typealias StepInAddressInfoClosure = (() throws -> SearchAddressResponse) -> Void
    typealias RefineAddressInfoClosure = (() throws -> SearchAddressResponse) -> Void
    typealias UpdatePasswordClosure = (() throws -> Void) -> Void

    /// Results of coverage information service call
    private(set) var profileInfo: ProfileResponse?

    /// Results of address information service call
    private(set) var addressInfo: InsuredAddressResponse?

    /// Results of search address information service call
    private(set) var searchAddressInfo: SearchAddressResponse?
    
    /// Results of search address information service call
    private(set) var stepInAddressInfo: SearchAddressResponse?

    /// Fetches email of user for a policy number
    ///
    /// - Parameter completion: Completion handler
    func getProfileDetails(completion: @escaping ProfileInfoClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }
        
        self.serviceConsumer.getProfileDetails(forPolicy: policyNumber) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.profileInfo = response
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Updates email of user for a policy number
    ///
    /// - emailBody completion: Dictionary of the email values
    /// - Parameter completion: Completion handler
    func updateEmail(with emailBody: [String: String], completion: @escaping UpdateEmailInfoClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }
        
        self.serviceConsumer.updateEmailDetails(forPolicy: policyNumber, emailBody: emailBody) { (innerClosure) in
            do {
                let _ = try innerClosure()
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }

        }
    }

    /// Fetches address of user for a policy number
    ///
    /// - Parameter completion: Completion handler
    func getAddressDetails(completion: @escaping AddressInfoClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }
        
        self.serviceConsumer.getAddressDetails(forPolicy: policyNumber) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.addressInfo = response
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Searches address of user for a policy number
    ///
    /// - Parameter completion: Completion handler
    func searchAddressDetails(with address: AddressRequest, completion: @escaping SearchAddressInfoClosure) {
        
        let addressBody: [String: Any] = [
            "adddressServiceRequest": [
                "city": address.city,
                "state": address.state,
                "streetAddress": address.streetAddress,
                "zip": address.zip
            ]
        ]

        self.serviceConsumer.searchAddress(with: addressBody) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.searchAddressInfo = response
                completion({ response })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Updates address of user for a policy number
    ///
    /// - Parameter completion: Completion handler
    func updateAddressDetails(with address: AddressRequest, completion: @escaping UpdateAddressClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }
        let addressBody: [String: Any] = [
            "adddressServiceRequest": [
                "city": address.city,
                "state": address.state,
                "streetAddress": address.streetAddress,
                "zip": address.zip,
                "policyNumber": policyNumber
            ]
        ]
        
        self.serviceConsumer.updateAddress(with: addressBody) {  (innerClosure) in
            do {
                let response = try innerClosure()
                completion({ response })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Steps in address of user based on moniker
    ///
    /// - Parameter completion: Completion handler
    func stepInAddress(with moniker: String, completion: @escaping StepInAddressInfoClosure) {
        
        let requestBody: [String: Any] = [
            "adddressServiceRequest": [
                "moniker": moniker
            ]
        ]
        
        self.serviceConsumer.stepInAddress(with: requestBody) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.stepInAddressInfo = response
                completion({ response })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Refines address of user based on moniker and refinement value
    ///
    /// - Parameter completion: Completion handler
    func refineAddress(with moniker: String, refinement: String, completion: @escaping RefineAddressInfoClosure) {
        
        let requestBody: [String: Any] = [
            "adddressServiceRequest": [
                "moniker": moniker,
                "refinementValue": refinement
            ]
        ]
        
        self.serviceConsumer.stepInAddress(with: requestBody) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.stepInAddressInfo = response
                completion({ response })
            }
            catch {
                completion({ throw error })
            }
        }
    }
    
    /// Updates password of user
    ///
    /// - Parameter completion: Completion handler
    func updatePassword(with body: [String: String], completion: @escaping UpdatePasswordClosure) {
        
        self.serviceConsumer.updatePassword(with: body) { (innerClosure) in
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
