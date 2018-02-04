//
//  AddCardRequest.swift
//  The General
//
//  Created by Leif Harrison on 11/22/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

struct BillingAddress {
    let street: String?
    let city: String?
    let state: String?
    let zip: String?
}

struct AddCardRequest {
    let policyNumber: String
    let firstName: String
    let lastName: String
    let cardNumber: String
    let month: Int
    let year: Int
    let address: BillingAddress?
    let saveForFuture: Bool
    let label: String?
    let preferred: Bool
}

struct UpdateCardRequest {
    let policyNumber: String
    let id: UInt
    let firstName: String?
    let lastName: String?
    let cardNumber: String?
    let month: Int?
    let year: Int?
    let address: BillingAddress?
    let label: String?
    let preferred: Bool
}

struct DeleteCardRequest: Encodable {
    let policyNumber: String
    let cardId: UInt
    let isForceDelete: Bool
}

struct AddBankAccountRequest {
    let policyNumber: String
    let routingNumber: String
    let accountNumber: String
    let saveForFuture: Bool
    let label: String?
    let preferred: Bool
}

struct UpdateBankAccountRequest {
    let policyNumber: String
    let id: UInt
    let label: String?
    let preferred: Bool
}

struct DeleteBankAccountRequest: Encodable {
    let policyNumber: String
    let bankAccountId: UInt
    let isForceDelete: Bool
}
