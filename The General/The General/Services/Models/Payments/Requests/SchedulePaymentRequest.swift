//
//  SchedulePaymentRequest.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 1/9/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct SchedulePaymentRequest: Encodable {
    // Similar to MakePaymentRequest
    var policyNumber: String
    var paymentAmount: Decimal
    var paymentDate: Date
    var paymentType: PaymentMethodType
    var paymentMethod: PaymentAmountMethodType
    var operationType: PaymentOperationType

    // Saved Card
    var paymentCardId: UInt?
    
    // Temporary Card
    var month: UInt?
    var year: UInt?
    var firstName: String?
    var lastName: String?
    var street: String?
    var city: String?
    var state: String?
    var zip: String?
    var tokenNumber: UInt?
    
    // Saved Bank Account
    var paymentBankId: UInt?
    
    // Temporary Bank Account
    var routingNumber: String?
    var accountNumber: String?

    init?(policyNumber: String, amount: Decimal, paymentAmountMethod: PaymentAmountMethodType, paymentMethodResponse: PaymentMethodResponse, paymentDate: Date) {
        self.policyNumber = policyNumber
        self.paymentAmount = amount
        self.operationType = .temporary
        self.paymentMethod = paymentAmountMethod
        self.paymentType = paymentMethodResponse.type
        self.paymentDate = paymentDate
        
        if paymentMethodResponse.type == .bankAccount {
            // Saved Bank Account
            if paymentMethodResponse.saveForLater {
                self.paymentBankId = paymentMethodResponse.id
            
            // Temporary Bank Account
            } else {
                guard let routingNumber = paymentMethodResponse.routingNumber,
                      let accountNumber = paymentMethodResponse.accountNumber else { return nil }
                
                self.routingNumber = routingNumber
                self.accountNumber = accountNumber
            }

        } else {
            // Saved Card
            if paymentMethodResponse.saveForLater {
                self.paymentCardId = paymentMethodResponse.id
            // Temporary Card
            } else {
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
                self.tokenNumber = paymentMethodResponse.id

            }
        }
    }
    
}
