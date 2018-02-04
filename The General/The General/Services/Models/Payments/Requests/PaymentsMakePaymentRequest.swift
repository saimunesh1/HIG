//
//  PaymentsMakePaymentRequest.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

enum PaymentOperationType: String, Codable {
    case temporary = "OneTime"
    case saved = "MultiTime"
}

enum PaymentAmountMethodType: String, Codable {
    case currentAmountDue = "CurrAmountDue"
    case renewalDownPayment = "RenewalDownPayment"
    case renewalDownPaymentPlusCurrentAmountDue = "RenewalDownPaymentPlus"
    case paidInFullRenewal = "PaidInFullRenewal"
    case nonRenewableFullPayoff = "PayoffAmount"
    case fullPayoff = "PayoffAmountExp"
    case otherAmount = "OtherAmount"
}

struct MakePaymentRequest: Encodable {
    var policyNumber: String
    var amount: Decimal
    var type: PaymentMethodType
    var selectedPaymentAmountMethod: PaymentAmountMethodType
    var operationType: PaymentOperationType
    
    // Only one of these should be set
    var card: MakePaymentCardInfo?
    var account: MakePaymentBankAccountInfo?
}

struct MakePaymentCardInfo: Encodable {
    // Saved Card
    var cardId: UInt?
    
    // Temporary Card
    var month: UInt?
    var year: UInt?
    var firstName: String?
    var lastName: String?
    var street: String?
    var city: String?
    var state: String?
    var zip: String?
    var token: UInt?
    
    init(cardId: UInt?, month: UInt?, year: UInt?, firstName: String?, lastName: String?, street: String?, city: String?, state: String?, zip: String?, token: UInt?) {
        self.cardId = cardId
        self.month = month
        self.year = year
        self.firstName = firstName
        self.lastName = lastName
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
        self.token = token
    }
    
    init?(paymentMethodResponse: PaymentMethodResponse) {
        guard paymentMethodResponse.type == .card else { return nil }
        
        if paymentMethodResponse.saveForLater {
            self.cardId = paymentMethodResponse.id
        }
        else {
            guard let month = paymentMethodResponse.month,
                let year = paymentMethodResponse.year,
                let firstName = paymentMethodResponse.firstName,
                let lastName = paymentMethodResponse.lastName,
                let street = paymentMethodResponse.street,
                let city = paymentMethodResponse.city,
                let state = paymentMethodResponse.state,
                let zip = paymentMethodResponse.zip else { return nil}
            
            self.month = month
            self.year = year
            self.firstName = firstName
            self.lastName = lastName
            self.street = street
            self.city = city
            self.state = state
            self.zip = zip
            self.token = paymentMethodResponse.id
        }
        
    }
}

struct MakePaymentBankAccountInfo: Encodable {
    // Saved Bank Account
    var accountId: UInt?
    
    // Temporary Bank Account
    var routingNumber: String?
    var accountNumber: String?
    
    init(accountId: UInt?, routingNumber: String?, accountNumber: String?) {
        self.accountId = accountId
        self.routingNumber = routingNumber
        self.accountNumber = accountNumber
    }
    
    init?(paymentMethodResponse: PaymentMethodResponse) {
        guard paymentMethodResponse.type == .bankAccount else { return nil }
        
        if paymentMethodResponse.saveForLater {
            self.accountId = paymentMethodResponse.id
        }
        else {
            guard let routingNumber = paymentMethodResponse.routingNumber,
                let accountNumber = paymentMethodResponse.accountNumber else { return nil }
            
            self.routingNumber = routingNumber
            self.accountNumber = accountNumber
        }
    }
}
