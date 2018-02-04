//
//  ProfileServiceConsumer.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/16/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

class ProfileServiceConsumer {
    
    let serviceManager = ServiceManager.shared
    
    typealias GetProfileDetailClosure = (() throws -> ProfileResponse) -> Void
    typealias UpdateEmailDetailClosure = (() throws -> Void) -> Void
    typealias GetAddressDetailClosure = (() throws -> InsuredAddressResponse) -> Void
    typealias SearchAddressClosure = (() throws -> SearchAddressResponse) -> Void
    typealias UpdateAddressClosure = (() throws -> UpdateResponse) -> Void
    typealias StepInAddressClosure = (() throws -> SearchAddressResponse) -> Void
    typealias RefineAddressClosure = (() throws -> SearchAddressResponse) -> Void
    typealias UpdatePasswordClosure = (() throws -> Void) -> Void

    /// Gets the email detail of user with policy
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number of the logged in user
    ///   - completion: Completion handler, returns ProfileResponse
    func getProfileDetails(forPolicy policyNumber: String, completion: @escaping GetProfileDetailClosure) {
        
        guard let access = SessionManager.accessToken else { return }
        let body = [ "tgt": access ]
        
        let request = self.serviceManager.request(type: .post, path: "/rest/auth/getEmail/\(policyNumber)", headers: nil, body: body)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode(ProfileResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }
    
    
    /// Updates the email detail of user with policy
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number of the logged in user
    ///   - completion: Completion handler, returns ProfileResponse
    func updateEmailDetails(forPolicy policyNumber: String, emailBody: [String: String], completion: @escaping UpdateEmailDetailClosure) {
        
        guard let access = SessionManager.accessToken else { return }
        var requestBody = emailBody
        requestBody["tgt"] = access
        
        let request = self.serviceManager.request(type: .post, path: "/rest/auth/updateEmail/\(policyNumber)", headers: nil, body: requestBody)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let _ = try innerClosure()
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Gets the insured address of user with policy
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number of the logged in user
    ///   - completion: Completion handler, returns ProfileResponse
    func getAddressDetails(forPolicy policyNumber: String, completion: @escaping GetAddressDetailClosure) {
        
        let request = self.serviceManager.request(type: .get, path: "/rest/addressService/getInsuredAddress/\(policyNumber)", headers: nil, body: nil)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any], let insured = responseData["insuredAddress"] as? [String: Any] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: insured, options: [])
                let responseModel = try JSONDecoder.shared.decode(InsuredAddressResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }
    
    /// Searches to check validity of the address of user with policy
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number of the logged in user
    ///   - completion: Completion handler, returns ProfileResponse
    func searchAddress(with body: [String: Any], completion: @escaping SearchAddressClosure) {
        
        let request = self.serviceManager.request(type: .post, path: "/rest/addressService/searchAddress", headers: nil, body: body)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode(SearchAddressResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }

    /// Update address of user with policy
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number of the logged in user
    ///   - completion: Completion handler, returns ProfileResponse
    func updateAddress(with body: [String: Any], completion: @escaping UpdateAddressClosure) {
        
        let request = self.serviceManager.request(type: .post, path: "/rest/addressService/processChangeOfAddress", headers: nil, body: body)
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

    /// Steps in address of user with policy
    ///
    /// - Parameters:
    ///   - body: body of request
    ///   - completion: Completion handler, returns ProfileResponse
    func stepInAddress(with body: [String: Any], completion: @escaping StepInAddressClosure) {
        
        let request = self.serviceManager.request(type: .post, path: "/rest/addressService/stepInAddress", headers: nil, body: body)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode(SearchAddressResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }

    /// Refine address of user
    ///
    /// - Parameters:
    ///   - body: body of request
    ///   - completion: Completion handler, returns ProfileResponse
    func refineAddress(with body: [String: Any], completion: @escaping RefineAddressClosure) {
        
        let request = self.serviceManager.request(type: .post, path: "/rest/addressService/refineAddress", headers: nil, body: body)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode(SearchAddressResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }

    /// Update password of user
    ///
    /// - Parameters:
    ///   - body: body of request
    ///   - completion: Completion handler, returns ProfileResponse
    func updatePassword(with body: [String: String], completion: @escaping UpdatePasswordClosure) {
        
        guard let access = SessionManager.accessToken else { return }
        let request = self.serviceManager.request(type: .post, path: "/rest/auth/updatePassword/\(access)", headers: nil, body: body)
        self.serviceManager.async(request: request) { (innerClosure) in
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
