//
//  PreloadingManager.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

/// Handles preloading data when the user signs in
class PreloadingManager {
    enum Notifications: String, NotificationName {
        case finished = "PreloadingManager.finished"
    }
    
    var isLoading: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSessionStarted), name: SessionManager.Notifications.sessionStarted.name, object: nil)
    }
    
    func startPreloadingData() {
        guard !self.isLoading else { return }
        
        self.isLoading = true
        let group = DispatchGroup()
		SettingsManager.refillUrl = nil

        // Dashboard
        group.enter()
        ApplicationContext.shared.dashboardManager.updateDashboardInfo(completion: { (innerClosure) in
            _ = try? innerClosure()
            group.leave()
        })

        group.enter()
        ApplicationContext.shared.dashboardManager.getPromo(completion: { (innerClosure) in
            _ = try? innerClosure()
            group.leave()
        })

        if let policyNumber = SessionManager.policyNumber {
            // Questionnaire
            group.enter()
            ApplicationContext.shared.fnolClaimsManager.getQuestionnaire(forPolicy: policyNumber) { (innerClosure) in
                _ = try? innerClosure()
                group.leave()
            }
            
            // Payment Due Details
            group.enter()
            ApplicationContext.shared.paymentsManager.getDueDetails(forPolicy: policyNumber) { (innerClosure) in
                _ = try? innerClosure()
                group.leave()
            }
			
			// Refill eligibility
			group.enter()
			ApplicationContext.shared.quotesManager.getQuoteRefill(forPolicy: policyNumber, completion: { (innerClosure) in
				if let quotesRefillUrl = try? innerClosure(), let url = quotesRefillUrl.url {
					SettingsManager.refillUrl = "\(ServiceManager.shared.webContentBaseURL)\(url)"
				}
				group.leave()
			})
        }
        
        group.notify(queue: .main, work: DispatchWorkItem(block: {
            self.isLoading = false
            NotificationCenter.default.post(name: Notifications.finished.name, object: nil)
        }))
    }
    
    
    // MARK: - Notifications
    @objc func handleSessionStarted() {
        self.startPreloadingData()
    }
}
