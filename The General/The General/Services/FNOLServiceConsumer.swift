//
//  FNOLServiceConsumer.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class FNOLServiceConsumer {
    typealias GetVahicleClosure = (() throws -> [String]) -> Void
    typealias GetQuestionnaireClosure = (() throws -> QuestionnaireResponse) -> Void
    typealias GetReferenceNumberClosure = (() throws -> GetReferenceNumberResponse) -> Void
    typealias SubmitClaimClosure = (() throws -> Void) -> Void
    typealias UploadPictureClosure = (() throws -> Void) -> Void
    
    let serviceManager = ServiceManager.shared
    
    /// Request a Questionnaire to start FNOL process.
    ///
    /// - Parameters:
    ///   - policyNumber: Account holder's policy number
    ///   - completion: Completion handler
    func getQuestionnaire(policyNumber: String, completion: @escaping GetQuestionnaireClosure) -> Void {
        
        let request = self.serviceManager.request(type: .get, path: "/rest/claimFNOL/questionnaires/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                
                if let jsonData = response.data {
                    let responseModel = try JSONDecoder().decode(QuestionnaireResponse.self, from: jsonData)
                    completion({ return responseModel })
                }
                
            }
            catch let error {
                completion({ throw error })
            }
        }
    }
    
    /// Request list of car makes for a given year.
    ///
    /// - Parameters:
    ///   - year: Year
    ///   - completion: Completion handler
    func getMakesForYear(year: String, completion: @escaping GetVahicleClosure) -> Void {
		let filteredYear = year == YearPicker.iDontKnow ? nil : year
        let qItem = URLQueryItem(name: "year", value: filteredYear)
        let paramPath = getURLQueryString(path: "/rest/claimFNOL/makes", parameters: [qItem])
        
        let request = self.serviceManager.request(type: .get, path: paramPath, headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            
            do {
                let response = try innerClosure()
                if let jsonData = response.jsonObject {
                    guard let responseModel = jsonData["response"] as? [String: Any],
                        let values = responseModel["makes"] as? [String] else{return}
                    completion({ return values })
                }
            }
            catch let error {
                completion({ throw error })
            }
        }
    }
    
    /// Request list of models for given year and make.
    ///
    /// - Parameters:
    ///   - make: Make of car
    ///   - year: Yea of car
    ///   - completion: Completion handler
    func getModelsForMakesYear(make: String, year: String, completion: @escaping GetVahicleClosure) -> Void {
		let filteredYear = year == YearPicker.iDontKnow ? nil : year
        let qItem = URLQueryItem(name: "year", value: filteredYear)
        let mItem = URLQueryItem(name: "make", value: make)
        
        let paramPath = getURLQueryString(path: "/rest/claimFNOL/models", parameters: [qItem, mItem])
        let request = self.serviceManager.request(type: .get, path: paramPath, headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                if let jsonData = response.jsonObject {
                    
                    guard let responseModel = jsonData["response"] as? [String: Any],
                         let values = responseModel["models"] as? [String] else{ return }
                    completion({ return values })
                }
            }
            catch let error {
                completion({ throw error })
            }
        }
    }
    
    /// Request a new reference number to start FNOL process.
    ///
    /// - Parameters:
    ///   - policyNumber: Account holder's policy number
    ///   - completion: Completion handler
    func getReferenceNumber(policyNumber: String, completion: @escaping GetReferenceNumberClosure) {
        let request = self.serviceManager.request(type: .get, path: "/rest/claimFNOL/referenceNumber/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                
                if let jsonData = response.data {
                    let responseModel = try JSONDecoder().decode(GetReferenceNumberResponse.self, from: jsonData)
                    completion({ return responseModel })
                }
            }
            catch let error {
                completion({ throw error })
            }
        }
    }
    
    /// Submit the answers for the questionnaire
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number associated with the claim
    ///   - referenceNumber: Reference number for the claim
    ///   - finalClaimUpload: Finalizes the claim for submission
    ///   - claimInformation: Answers for the questionnaire
    ///   - completion: Completion handler
    func submitClaim(policyNumber: String, referenceNumber: String, finalClaimUpload: Bool, claimInformation: [String: Any], completion: @escaping SubmitClaimClosure) {
        var requestBody: [String: Any] = [
            "policyNumber": policyNumber,
            "referenceNumber": referenceNumber,
            "finalClaimUpload": finalClaimUpload
        ]
        requestBody.merge(claimInformation) { (current, _) in current }
        
        let request = self.serviceManager.request(type: .post, path: "/rest/claimFNOL/submitClaim", headers: nil, body: requestBody)
        
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
    
    /// Shortcut for uploading a single picture to a claim
    ///
    /// - Parameters:
    ///   - picture: Image
    ///   - pictureId: Id assigned to the picture in the claim
    ///   - referenceNumber: Reference number for the claim
    ///   - finalClaimUpload: Finalizes the claim for submission
    ///   - completion: Completion handler
    func uploadPicture(_ picture: UIImage, forId pictureId: String, referenceNumber: String, finalClaimUpload: Bool, completion: @escaping UploadPictureClosure) {
        self.uploadPicturesWithIds([pictureId: picture], referenceNumber: referenceNumber, finalClaimUpload: finalClaimUpload, completion: completion)
    }
    
    /// Upload multiple pictures to a claim
    ///
    /// - Parameters:
    ///   - picturesMapping: Key is id assigned to picture in the claim, value is the image
    ///   - referenceNumber: Reference number for the claim
    ///   - finalClaimUpload: Finalizes the claim for submission
    ///   - completion: Completion handler
    func uploadPicturesWithIds(_ picturesMapping: [String: UIImage], referenceNumber: String, finalClaimUpload: Bool, completion: @escaping UploadPictureClosure) {
        // Generate pictures array structure
        var pictures: [[String: String]] = []
        for (id, image) in picturesMapping {
            pictures.append([
                "pictureId": id,
                "pictureData": UIImageJPEGRepresentation(image, 0.8)!.base64EncodedString()
            ])
        }
        
        let requestBody: [String: Any] = [
            "referenceNumber": referenceNumber,
            "finalClaimUpload": finalClaimUpload,
            "pictures": pictures
        ]
        
        let request = self.serviceManager.request(type: .post, path: "/rest/claimFNOL/uploadPicturesForClaim", headers: nil, body: requestBody)
        
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


// MARK: - Private
extension FNOLServiceConsumer {
    /// Build URL with query string parameters
    ///
    /// - Parameters:
    ///   - path: Base path of request
    ///   - parameters: Query string parameters
    /// - Returns: Final URL
    fileprivate func getURLQueryString(path: String, parameters: [URLQueryItem]) -> String {
        var urlComponents = URLComponents(string: path)!
        urlComponents.queryItems = parameters
        return (urlComponents.url?.absoluteString)!
    }
}
