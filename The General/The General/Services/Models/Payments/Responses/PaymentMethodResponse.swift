//
//  PaymentMethodResponse.swift
//  The General
//
//  Created by Derek Bowen on 10/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

enum PaymentMethodType: String, Codable {
    case card = "CARD"
    case bankAccount = "BANKACCOUNT"
}

struct PaymentMethodResponse: Decodable, Encodable {
    let type: PaymentMethodType
    let id: UInt
    let last4Digits: String
    let label: String?
    let preferred: Bool
    
    // Card
    let month: UInt?
    let year: UInt?
    let firstName: String?
    let lastName: String?
    var street: String?
    var city: String?
    var state: String?
    var zip: String?
    
    // Bank Account
    let routingNumber: String?
    
    // Transients
    var saveForLater: Bool = true
    var accountNumber: String? = nil
    
    var displayName: String {
        get {
            switch self.type {
            case .card:
                return "Credit Card ending in \(self.last4Digits)"
                
            case .bankAccount:
                return "Bank Account ending in \(self.last4Digits)"
            }
        }
    }
    
    /// Keys to decode
    private enum CodingKeys: String, CodingKey {
        case type
        case id
        case last4Digits
        case label
        case preferred
        case month
        case year
        case firstName
        case lastName
        case street
        case city
        case state
        case zip
        case routingNumber
    }
}

func ==(lhs: PaymentMethodResponse, rhs: PaymentMethodResponse) -> Bool {
    return (lhs.type == rhs.type) &&
        (lhs.id == rhs.id) &&
        (lhs.last4Digits == rhs.last4Digits) &&
        (lhs.label == rhs.label) &&
        (lhs.preferred == rhs.preferred) &&
        (lhs.month == rhs.month) &&
        (lhs.year == rhs.year) &&
        (lhs.firstName == rhs.firstName) &&
        (lhs.lastName == rhs.lastName) &&
        (lhs.street == rhs.street) &&
        (lhs.city == rhs.city) &&
        (lhs.state == rhs.state) &&
        (lhs.zip == rhs.zip) &&
        (lhs.routingNumber == rhs.routingNumber)
}
