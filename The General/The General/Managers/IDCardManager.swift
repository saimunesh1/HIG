//
//  IDCardManager.swift
//  The General
//
//  Created by Hopkinson, Todd (US - Denver) on 1/4/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

enum IDCardErrorType: Error {
    case noPolicyNumber
}

class IDCardManager {

    lazy var serviceConsumer = IDCardServiceConsumer()
    static var secureKeychainIDCardsKey = "IDCardsJSONStringKey"
    static var secureKeychainPolicyLastSyncKey = "IDCardsPolicyLastSyncDateKey"
    static var secureKeychainPolicyNumberKey = "IDCardsPolicyNumberKey"
    static var secureKeychainEffectiveDatesKey = "secureKeychainEffectiveDatesKey"
    static var syncDaysThreshold = 7 // TODO: replace this TBD with the actual number days past which no syncs causes ID Cards to be no longer available when logged out or invalid policy
    
    enum IDCardsDataResponseErrorType: Error {
        case unexpectedResponse
        case userHasNotSyncedForTooLongAndMustLogin
        case unknown
    }
    
    /// Request id card
    ///
    /// - Parameters:
    ///  - policyNumber: Policy number (string)
    ///  - completion: Completion handler
    func getIDCard(policyNumber: String, completion: @escaping IDCardInfoClosure) {
        
        // When user is logged-out the response should be the local cached version intended for logged-out access
        let isLoggedOut = !SessionManager.isSessionValid
        if isLoggedOut {
            if IDCardManager.isPolicySyncThresholdExpired {
                completion({ throw IDCardsDataResponseErrorType.userHasNotSyncedForTooLongAndMustLogin })
            } else {
                if let infoResponse = self.getCachedIDCardInfoResponse() {
                    completion({ return infoResponse })
                } else {
                    completion({ throw IDCardsDataResponseErrorType.unknown })
                }
            }
            return
        }

        serviceConsumer.getIDCardInfo(policyNumber: policyNumber) { [weak self] (innerClosure) in
            guard let idCardsInfoResponse = try? innerClosure() else {
                completion({ throw IDCardsDataResponseErrorType.unexpectedResponse })
                return
            }
            if let jsonString = idCardsInfoResponse.jsonDataCacheBase64String {
                self?.saveLocalIDCardInfoResponse(jsonDataBase64String: jsonString)
            }
            completion({ return idCardsInfoResponse })
        }
    }
    
    static var isPolicyLapsed: Bool {
        if let dashboardResponse = ApplicationContext.shared.dashboardManager.dashboardInfo, let policyStatus = dashboardResponse.policyStatus {
            switch policyStatus {
            case .lapsed, .canceled:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    static var isPolicySyncThresholdExpired: Bool {
        if  let lastSynced = try? SecureKeychain.string(forKey: secureKeychainPolicyLastSyncKey),
            let lastSyncedDateString = lastSynced,
            let syncedDate = DateFormatter().date(from: lastSyncedDateString), let daysApart = Calendar.current.dateComponents([.day], from: syncedDate, to: Date()).day {
            if daysApart > syncDaysThreshold {
                return true
            }
        }
        return false
    }
    
    static var isAllowedFullIDCardsDisplayIfLoggedOut: Bool {
        let isAllowed = PreferencesManager.allowIDwhenLoggedOut
        let isCached = IDCardManager.isCardIDInfoCached
        return (isAllowed && isCached)
    }
    
    func getCachedIDCardInfoResponse() -> IDCardInfoResponse? {
        if  let jsonDataBase64String = try? SecureKeychain.string(forKey: IDCardManager.secureKeychainIDCardsKey),
            let jsonString = jsonDataBase64String,
            let response = IDCardInfoResponse.idCardInforResponseFromCache(jsonDataCacheBase64String: jsonString) {
                return response
            }
        return nil
    }
    
    static func getCachedIDCardPolicyNumber() -> String? {
        if let policyNumber = try? SecureKeychain.string(forKey: IDCardManager.secureKeychainPolicyNumberKey), let policyNumberString = policyNumber {
            return policyNumberString
        }
        return nil
    }
    
    static var isCardIDInfoCached: Bool {
        if let _ = try? SecureKeychain.string(forKey: IDCardManager.secureKeychainIDCardsKey) {
            return true
        }
        return false
    }
    
    static var effectiveDateRange: String {
        if  let effectiveDate = ApplicationContext.shared.dashboardManager.dashboardInfo?.policyEffectiveDate,
            let endDate = ApplicationContext.shared.dashboardManager.dashboardInfo?.policyEndDate {
            let from = DateFormatter.twoDigitMonthDayFourDigitYear.string(from: effectiveDate)
            let to = DateFormatter.twoDigitMonthDayFourDigitYear.string(from: endDate)
            return "\(from)-\(to)"
        }
        return ""
    }
    
    static func getCachedEffectiveDateRangeString() -> String {
        if let cached = try? SecureKeychain.string(forKey: IDCardManager.secureKeychainEffectiveDatesKey), let cachedString = cached {
            return cachedString
        }
        return ""
    }
    
    private func saveLocalIDCardInfoResponse(jsonDataBase64String: String) {
        do {
            try SecureKeychain.setString(jsonDataBase64String, forKey: IDCardManager.secureKeychainIDCardsKey)
            try SecureKeychain.setString(Date().dateNowString(), forKey: IDCardManager.secureKeychainPolicyLastSyncKey)
            if let policyNumber = SessionManager.policyNumber {
                try SecureKeychain.setString(policyNumber, forKey: IDCardManager.secureKeychainPolicyNumberKey)
            }
            try SecureKeychain.setString(IDCardManager.effectiveDateRange, forKey: IDCardManager.secureKeychainEffectiveDatesKey)
        } catch {
            print("trouble caching info card json string, error \(error)")
        }
    }
}
