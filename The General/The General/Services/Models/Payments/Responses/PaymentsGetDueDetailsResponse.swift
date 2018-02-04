
//
//  PaymentsGetDueDetailsResponse.swift
//  The General
//
//  Created by Derek Bowen on 10/16/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

enum StatusType: String, Decodable {
	case active = "A"
	case canceled = "C"
	case entry = "E"
	case lapsed = "L"
}

struct PaymentsGetDueDetailsResponse: Decodable {
    let autoDebitAvailable: Bool
    let autoDebitEnabled: Bool
    let autoDebitEnrolledType: String?
    let autoDebitEnrolledLast4: String?
    let canAcceptPayment: Bool
    let generalNotifications: [PaymentsGeneralNotificationResponse]?
//    let paymentNotifications
    let displayRenewalDownPaymentOption: Bool
    let renewalDownPaymentAmount: CoercingDecimal?
    let renewalDownPaymentAmountLabel: String?
    let displayFullPayoffAmountOption: Bool
    let fullPayoffAmount: CoercingDecimal?
    let fullPayoffAmountLabel: String?
    let displayRenewalDownPaymentPlusCurrentDueOption: Bool
    let renewalDownPaymentPlusCurrentDueAmount: CoercingDecimal?
    let renewalDownPaymentPlusCurrentDueAmountLabel: String?
    let displayPaidInFullRenewalOption: Bool
    let paidInFullRenewalAmount: CoercingDecimal?
    let paidInFullRenewalAmountLabel: String?
    let displayNonRenewableFullPayoffAmountOption: Bool
    let nonRenewableFullPayoffAmount: CoercingDecimal?
    let nonRenewableFullPayoffAmountLabel: String?
    let displayCurrentAmountDueOption: Bool
    let currentAmountDue: CoercingDecimal?
    let currentAmountDueLabel: String?
    let displayOtherAmountOption: Bool
    let otherAmount: CoercingDecimal?
    let otherAmountLabel: String?
    let billingFirstName: String?
    let billingLastName: String?
    let billingStreet: String?
    let billingCity: String?
    let billingState: String?
    let billingZip: String?
    let billingEmail: String?
    let minimumPayment: CoercingDecimal?
    let maximumPayment: CoercingDecimal?
    let currentDueDate: Date?
    let canReinstate: Bool
    let status: StatusType?
    let lapseReason: String?
    
    var dueDateDisplay: String? {
        get {
            guard let dueDate = self.currentDueDate else {
                return nil
            }
            
            return DateFormatter.monthDay.string(from: dueDate)
        }
    }
    
    var autopayPaymentMethodDisplay: String {
        get {
            guard let autoDebitEnrolledType = self.autoDebitEnrolledType, let last4 = self.autoDebitEnrolledLast4 else {
                return "N/A"
            }
            switch autoDebitEnrolledType {
            case "creditcard":
                return "Credit Card ending in \(last4)"
            case "bankaccount":
                return "Bank Account ending in \(last4)"
            default:
                return "Payment ending in \(last4)"
            }
        }
    }
}

extension PaymentsGetDueDetailsResponse {
    func availablePaymentAmountMethods() -> [PaymentAmountMethodType] {
        var availableMethods: [PaymentAmountMethodType] = []
        
        if self.displayCurrentAmountDueOption {
            availableMethods.append(.currentAmountDue)
        }
        if self.displayFullPayoffAmountOption {
            availableMethods.append(.fullPayoff)
        }
        if self.displayPaidInFullRenewalOption {
            availableMethods.append(.paidInFullRenewal)
        }
        if self.displayRenewalDownPaymentOption {
            availableMethods.append(.renewalDownPayment)
        }
        if self.displayNonRenewableFullPayoffAmountOption {
            availableMethods.append(.nonRenewableFullPayoff)
        }
        if self.displayRenewalDownPaymentPlusCurrentDueOption {
            availableMethods.append(.renewalDownPaymentPlusCurrentAmountDue)
        }
        if self.displayOtherAmountOption {
            availableMethods.append(.otherAmount)
        }
        
        return availableMethods
    }
}
