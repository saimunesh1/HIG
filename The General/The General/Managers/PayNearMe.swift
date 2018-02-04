//
//  PayNearMe.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 12/19/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

enum PayNearMeIssue:Error {
    case missingPolicyNumber
    case serviceNotResponding
    case interpretationFailed
    case other
}

class PayNearMe {
    
    open class func activate(withAmount amount: Decimal, complete: @escaping (_ url: URL?, _ issue: PayNearMeIssue?) -> ()) {
        do {
            AnalyticsManager.track(event: .paymentsPayNearMeInitiated)
            try ApplicationContext.shared.paymentsManager.activatePayNearMe(withAmount: amount, success: { (url) in
                AnalyticsManager.track(event: .paymentsPayNearMeCompleted)
                complete(url, nil)
                
            }) { issue in // Issues due to server interaction
                AnalyticsManager.track(event: .paymentsPayNearMeDeclined)
                complete(nil, issue)
            }
            
        } catch let issue { // Immediate issues such as missing parameters for the call
            complete(nil, issue as? PayNearMeIssue)
        }
    }
}
