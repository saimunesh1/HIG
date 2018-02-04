//
//  Formatters+Shared.swift
//  The General
//
//  Created by Derek Bowen on 10/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter
    }()
}

extension ByteCountFormatter {
    static let file: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB]
        formatter.countStyle = .file
        
        return formatter
    }()
}

extension NumberFormatter {
    static func phoneNumber(from sourcePhoneNumber: String) -> String {
        let digitsOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = digitsOnly.count
        let hasLeadingOne = digitsOnly.hasPrefix("1")

        guard length == 10 || (length == 11 && hasLeadingOne) else {
            return ""
        }
        
        switch length {
        case 10:
            let p1 = digitsOnly.startIndex
            let p2 = digitsOnly.index(p1, offsetBy: 3)
            let p3 = digitsOnly.index(p2, offsetBy: 3)
            let p4 = digitsOnly.index(p3, offsetBy: 4)

            return "(\(digitsOnly[p1..<p2])) \(digitsOnly[p2..<p3])-\(digitsOnly[p3..<p4])"
        default:
            let p1 = digitsOnly.index(digitsOnly.startIndex, offsetBy: 1)
            let p2 = digitsOnly.index(p1, offsetBy: 3)
            let p3 = digitsOnly.index(p2, offsetBy: 3)
            let p4 = digitsOnly.index(p3, offsetBy: 4)

            return "1 (\(digitsOnly[p1..<p2])) \(digitsOnly[p2..<p3])-\(digitsOnly[p3..<p4])"
        }
    }
}
