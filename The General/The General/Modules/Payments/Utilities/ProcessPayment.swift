//
//  ProcessPayment.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ProcessPayment {
    static func displayText() -> String {
        let entries = ApplicationContext.shared.paymentsManager.activeMakePaymentSession?.paymentEntries ?? [MakePaymentEntry]()
        
        if entries.count == 1 {
            return "Processing credit card ending in \(entries.first!.paymentMethod!.last4Digits)"
        } else {
            return "Processing Payments"
        }
    }
}
