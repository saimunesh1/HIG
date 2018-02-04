//
//  PolicyManager.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

class PolicyManager {
    
    let serviceConsumer = PolicyServiceConsumer()
    
    typealias UpdateCoverageDetailsClosure = (() -> Void) -> Void
    typealias UpdateCoverageInfoClosure = (() throws -> Void) -> Void
    typealias UpdateDriversInfoClosure = (() throws -> Void) -> Void
    typealias UpdateVehicleInfoClosure = (() throws -> Void) -> Void
    typealias UpdateAgentInfoClosure = (() throws -> Void) -> Void
    typealias GetIDCardProofClosure = (() throws -> IDCardProofResponse) -> Void
    typealias GetEsignClosure = (() throws -> EsignResponse) -> Void
    typealias GetPolicyHistoryClosure = (() throws -> [PolicyHistoryResponse]) -> Void

    /// Results of coverage information service call
    private(set) var coverageInfo: CoverageResponse?

    /// Results of drivers information service call
    private(set) var driverInfo: [DriversResponse]?

    /// Results of vehicles information service call
    private(set) var vehicleInfo: [VehicleResponse]?
    
    /// Results of agent information service call
    private(set) var agentInfo: AgentResponse?
    
    /// Updates Coverage Info for a policy number
    ///
    /// - Parameter completion: Completion handler
    func getCoverageInfo(completion: @escaping UpdateCoverageInfoClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }
        
        self.serviceConsumer.getCoverageDetail(forPolicy: policyNumber) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.coverageInfo = response
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Updates Driver Info for a policy number
    ///
    /// - Parameter completion: Completion handler
    func getDriverInfo(completion: @escaping UpdateDriversInfoClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }
        
        self.serviceConsumer.getDriverDetail(forPolicy: policyNumber) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.driverInfo = response
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }
    
    /// Updates Vehicle Info for a policy number
    ///
    /// - Parameter completion: Completion handler
    func getVehicleInfo(completion: @escaping UpdateVehicleInfoClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }
        
        self.serviceConsumer.getVehicleDetail(forPolicy: policyNumber) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.vehicleInfo = response
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Updates Agent Info for a policy number
    ///
    /// - Parameter completion: Completion handler
    func getAgentInfo(completion: @escaping UpdateAgentInfoClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }

        self.serviceConsumer.getAgentDetail(forPolicy: policyNumber) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.agentInfo = response
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }
    
    /// Updates Agent Info for a policy number
    ///
    /// - forPolicy: Policy number
    /// - driverCount: number of drivers
    /// - vehicleCount: number of vehicles
    /// - spanish: Boolean indicating if a spanish language document is requested
    /// - Parameter completion: Completion handler
    func getProofOfInsurance(forPolicy: String, driverCount: Int, vehicleCount: Int, spanish: Bool, completion: @escaping GetIDCardProofClosure) {
        
        self.serviceConsumer.getProofOfInsurance(forPolicy: forPolicy, spanish: spanish, driverCount: driverCount, vehicleCount: vehicleCount) { (innerClosure) in
            do {
                let response = try innerClosure()
                completion({
                    return response
                })
            }
            catch {
                completion({ throw error })
            }
        }
    }
    
    /// Fetches Esign Info for a policy number
    ///
    /// - Parameter completion: Completion handler
    func getEsign(completion: @escaping GetEsignClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }
        
        self.serviceConsumer.getEsignResponse(forPolicy: policyNumber) { (innerClosure) in
            do {
                let response = try innerClosure()
                completion({ response })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Fetches policy history for a policy number
    ///
    /// - Parameter completion: Completion handler
    func getPolicyHistory(completion: @escaping GetPolicyHistoryClosure) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            completion({ throw DashboardErrorType.noPolicyNumber })
            return
        }
        
        self.serviceConsumer.getPolicyHistory(forPolicy: policyNumber) { (innerClosure) in
            do {
                let response = try innerClosure()
                completion({ response })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Fetches response for all the modules and notifies
    ///
    /// - Parameter completion: Completion handler
    func fetchCoverageResponse(completion: @escaping UpdateCoverageDetailsClosure) {
        
        let group = DispatchGroup()
        if let _ = SessionManager.policyNumber {
            
            // Get Coverage Info
            group.enter()
            ApplicationContext.shared.policyManager.getCoverageInfo(completion: { (innerClosure) in
                _ = try? innerClosure()
                group.leave()
            })
            
            // Get Driver details
            group.enter()
            ApplicationContext.shared.policyManager.getDriverInfo(completion: { (innerClosure) in
                _ = try? innerClosure()
                group.leave()
            })
            
            // Get Vehicle details
            group.enter()
            ApplicationContext.shared.policyManager.getVehicleInfo(completion: { (innerClosure) in
                _ = try? innerClosure()
                group.leave()
            })
            
            // Get Agent details
            group.enter()
            ApplicationContext.shared.policyManager.getAgentInfo(completion: { (innerClosure) in
                _ = try? innerClosure()
                group.leave()
            })
            
        }
        
        group.notify(queue: .main, work: DispatchWorkItem(block: {
            completion({ /* Success */ })
        }))

    }

}
