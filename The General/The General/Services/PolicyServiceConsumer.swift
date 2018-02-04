//
//  PolicyManager.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

class PolicyServiceConsumer {
    let serviceManager = ServiceManager.shared
    
    typealias GetCoverageDetailClosure = (() throws -> CoverageResponse) -> Void
    typealias GetDriverDetailClosure = (() throws -> [DriversResponse]) -> Void
    typealias GetVehicleDetailClosure = (() throws -> [VehicleResponse]) -> Void
    typealias GetAgentDetailClosure = (() throws -> AgentResponse) -> Void
    typealias GetIDCardProofClosure = (() throws -> IDCardProofResponse) -> Void
    typealias GetEsignClosure = (() throws -> EsignResponse) -> Void
    typealias GetPolicyHistoryClosure = (() throws -> [PolicyHistoryResponse]) -> Void

    /// Gets a summary of Coverage information to display on the policy coverage details screen
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number to get Agent sumamry for
    ///   - completion: Completion handler, returns AgentResponse
    func getCoverageDetail(forPolicy policyNumber: String, completion: @escaping GetCoverageDetailClosure) {
        let request = self.serviceManager.request(type: .get, path: "/rest/policyService/coverage/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode(CoverageResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }

    /// Gets a summary of Drivers information to display on the policy coverage details screen
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number to get Agent sumamry for
    ///   - completion: Completion handler, returns AgentResponse
    func getDriverDetail(forPolicy policyNumber: String, completion: @escaping GetDriverDetailClosure) {
        let request = self.serviceManager.request(type: .get, path: "/rest/policyService/drivers/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any], let drivers = responseData["drivers"] as? [[String: Any]] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: drivers, options: [])
                let responseModel = try JSONDecoder.shared.decode([DriversResponse].self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }

    /// Gets a summary of vehicle information to display on the policy coverage details screen
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number to get Agent sumamry for
    ///   - completion: Completion handler, returns AgentResponse
    func getVehicleDetail(forPolicy policyNumber: String, completion: @escaping GetVehicleDetailClosure) {
        let request = self.serviceManager.request(type: .get, path: "/rest/policyService/vehicles/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any], let vehicles = responseData["vehicles"] as? [[String: Any]] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: vehicles, options: [])
                let responseModel = try JSONDecoder.shared.decode([VehicleResponse].self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }
    
    /// Gets a summary of Agent information to display on the policy coverage details screen
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number to get Agent sumamry for
    ///   - completion: Completion handler, returns AgentResponse
    func getAgentDetail(forPolicy policyNumber: String, completion: @escaping GetAgentDetailClosure) {
        let request = self.serviceManager.request(type: .get, path: "/rest/policyService/policy/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode(AgentResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }
    
    /// Gets a pdf (base 64 encoded string) proof of insurance document to display on the Insurance Verification -> Proof of Insurance screen
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number
    ///   - spanish: Boolean indicating if a spanish language document is requested
    ///   - driverCount: number of drivers
    ///   - vehicleCount: number of vehicles
    ///   - completion: Completion handler, returns IDCardProofResponse
    func getProofOfInsurance(forPolicy policyNumber: String, spanish: Bool, driverCount: Int, vehicleCount: Int, completion: @escaping GetIDCardProofClosure) {

        func formatCountParam(_ count: Int) -> String {
            var countString = "1"
            if count > 1 {
                for (i) in 2...count {
                   countString.append(",\(i)")
                }
            }
            return countString
        }
        
        let languageParam = URLQueryItem(name: "spanish", value: spanish ? "true" : "false" )
        let driverCountParam = URLQueryItem(name: "driverNumbers", value: formatCountParam(driverCount)) // TODO: replace with actual values according to expected pattern
        let vehicleCountParam = URLQueryItem(name: "vehicleNumbers", value: formatCountParam(vehicleCount)) // // TODO: replace with actual values according to expected pattern
        let responseChannelParam = URLQueryItem(name: "responseChannel", value: "Print")
        var pathURLComponents = URLComponents(string: "/rest/policyService/getIdCard/\(policyNumber)")!
        pathURLComponents.queryItems = [vehicleCountParam, driverCountParam, languageParam, responseChannelParam]
        let paramPath = (pathURLComponents.url?.absoluteString)!

        let request = self.serviceManager.request(type: .get, path: paramPath, headers: nil, body: nil)

        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let pdfString = json["data"] as? String else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let responseModel = IDCardProofResponse(message: json["message"] as? String, success: json["success"] as? Bool, pdfBase64: pdfString)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }
    
    /// Gets esign requirement for a policy
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number to get Agent sumamry for
    ///   - completion: Completion handler, returns AgentResponse
    func getEsignResponse(forPolicy policyNumber: String, completion: @escaping GetEsignClosure) {
        let request = self.serviceManager.request(type: .get, path: "/rest/policyService/eSign/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode(EsignResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }

    /// Gets the policies history for a given policy
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number to get Agent sumamry for
    ///   - completion: Completion handler, returns GetPolicyHistoryClosure
    func getPolicyHistory(forPolicy policyNumber: String, completion: @escaping GetPolicyHistoryClosure) {
        let request = self.serviceManager.request(type: .get, path: "/rest/policyService/history/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()

                guard let json = response.jsonObject, let responseData = json["data"] as? [[String: Any]] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }

                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode([PolicyHistoryResponse].self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }

}
