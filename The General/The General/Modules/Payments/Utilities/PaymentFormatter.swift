//
//  CurrencyFormatter.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 12/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PaymentFormatter: Any {
    static func accountLabel(for paymentMethod: PaymentMethodResponse) -> String {
        switch paymentMethod.type {
        case .card:
            if let label = paymentMethod.label, !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return label
            }
            else {
                return String(format: NSLocalizedString("payments.ui.cardname", comment: ""), paymentMethod.last4Digits)
            }
            
        case .bankAccount:
            if let label = paymentMethod.label, !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return label
            }
            else {
                return String(format: NSLocalizedString("payments.ui.accountname", comment: ""), paymentMethod.last4Digits)
            }
        }

    }

    static func shortAccountLabel(for paymentMethod: PaymentMethodResponse) -> String {
        switch paymentMethod.type {
        case .card:
            if let label = paymentMethod.label, !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return label
            }
            else {
                return String(format: NSLocalizedString("payments.ui.shortcardname", comment: ""), paymentMethod.last4Digits)
            }
            
        case .bankAccount:
            if let label = paymentMethod.label, !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return label
            }
            else {
                return String(format: NSLocalizedString("payments.ui.shortaccountname", comment: ""), paymentMethod.last4Digits)
            }
        }
        
    }

    static func currency(for amount: Decimal) -> String {
        return NumberFormatter.currency.string(from: amount as NSDecimalNumber) ?? ""
    }
}
