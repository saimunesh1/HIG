//
//  DashboardResponse.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

struct DashboardResponse: Decodable {
    // Policy
    let insuredName: String?
    let companyNumber: String?
    let policyStatus: StatusType?
    let policyEffectiveDate: Date?
    let policyEndDate: Date?
    let hasRoadsideAssistanceFlag: Bool
    let roadsideAssistancePhone: String?
    let isRenewable: Bool
    let driverInfo: [PolicyDriverInfoResponse]?
    let vehicleInfo: [PolicyVehicleInfoResponse]?
    
    // Payments
    let canAcceptPayment: Bool
    let currentDueAmount: CoercingDecimal?
    let currentDueDate: Date?
    
    // Claims
    let claims: [ClaimEntry]?
    
    // Quotes
    let quotes: [QuoteResponse]?
    
    enum CodingKeys: String, CodingKey {
        case insuredName
        case companyNumber
        case policyStatus
        case policyEffectiveDate
        case policyEndDate
        case hasRoadsideAssistanceFlag = "hasroadsideAssistanceFlag"
        case roadsideAssistancePhone
        case isRenewable
        case driverInfo
        case vehicleInfo
        
        // Payments
        case canAcceptPayment
        case currentDueAmount
        case currentDueDate
        
        // Claims
        case claimsInfo
        case claimsData = "data"

        // Quotes
        case quoteInfo = "quoteInfo"
        case quotes = "quotes"
    }
    
    enum QuoteInfoKeys: String, CodingKey {
        case quotes
    }
    
    enum ClaimsInfoKeys: String, CodingKey {
        case claims
    }
}

extension DashboardResponse {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.insuredName = try? values.decode(String.self, forKey: .insuredName)
        self.companyNumber = try? values.decode(String.self, forKey: .companyNumber)
        self.policyStatus = try? values.decode(StatusType.self, forKey: .policyStatus)
        self.policyEffectiveDate = try? values.decode(Date.self, forKey: .policyEffectiveDate)
        self.policyEndDate = try? values.decode(Date.self, forKey: .policyEndDate)
        self.hasRoadsideAssistanceFlag = (try? values.decode(Bool.self, forKey: .hasRoadsideAssistanceFlag)) ?? false
        self.roadsideAssistancePhone = try? values.decode(String.self, forKey: .roadsideAssistancePhone)
        self.isRenewable = (try? values.decode(Bool.self, forKey: .isRenewable)) ?? false
        self.driverInfo = try? values.decode([PolicyDriverInfoResponse].self, forKey: .driverInfo)
        self.vehicleInfo = try? values.decode([PolicyVehicleInfoResponse].self, forKey: .vehicleInfo)
        self.canAcceptPayment = (try? values.decode(Bool.self, forKey: .canAcceptPayment)) ?? false
        self.currentDueAmount = try? values.decode(CoercingDecimal.self, forKey: .currentDueAmount)

        if let date = try? values.decode(String.self, forKey: .currentDueDate) {
            self.currentDueDate = DateFormatter.iso8601.date(from: date)
        } else {
            self.currentDueDate = nil
        }

        // the dashboard JSON returns quotes in an envelope if the user has a policy, otherwise not
        if let quoteInfo = try? values.nestedContainer(keyedBy: QuoteInfoKeys.self, forKey: .quoteInfo) {
            self.quotes = try? quoteInfo.decode([QuoteResponse].self, forKey: .quotes)
        } else {
            self.quotes = try? values.decode([QuoteResponse].self, forKey: .quotes)

        }

        if let claimsInfoValues = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .claimsInfo),
            let claimsResponse = try? claimsInfoValues.decode(ClaimListResponse.self, forKey: .claimsData) {
            self.claims = claimsResponse.claims
        } else {
            self.claims = []
        }
    }
}

extension DashboardResponse {
    var hasPolicy: Bool {
        return policyEffectiveDate != nil
    }
    
    var isPendingPolicy: Bool {
        return policyStatus == .entry
    }

    var isExpiredPolicy: Bool {
        guard let _ = policyEffectiveDate, let policyEndDate = policyEndDate else {
            return false
        }
        
        // if end date is in the past it's expired
        return policyEndDate.timeIntervalSince(Date()) < 0.0
    }
}
