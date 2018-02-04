//
//  DashboardManager.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

enum DashboardErrorType: Error {
    case noPolicyNumber
}

class DashboardManager {
    private let serviceConsumer = DashboardServiceConsumer()
    
    typealias UpdateDashboardInfoClosure = (() throws -> Void) -> Void
    typealias GetPromoClosure = (() throws -> Void) -> Void

    /// Results of dashboard information service call
    private(set) var dashboardInfo: DashboardResponse?
    
    /// Promo to display
    static var promo: GetFeaturedPromoResponse?

    func clearDashboardInfo() {
        dashboardInfo = nil
    }
    
    /// Updates dashboardInfo with summary of information to display on the dashboard
    ///
    /// - Parameter completion: Completion handler
    func updateDashboardInfo(completion: @escaping UpdateDashboardInfoClosure) {
        self.serviceConsumer.getDashboardInfo(forPolicy: SessionManager.policyNumber) { [weak self] (innerClosure) in
            do {
                let response = try innerClosure()
                self?.dashboardInfo = response
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    func getPromo(completion: @escaping GetPromoClosure) {
        self.serviceConsumer.getFeaturedPromo() { [weak self] (innerClosure) in
            do {
                DashboardManager.promo = try innerClosure()
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }
}
