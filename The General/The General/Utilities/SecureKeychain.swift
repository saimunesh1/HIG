//
//  SecureKeychain.swift
//  The General
//
//  Created by Derek Bowen on 10/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

public enum KeychainError: Error {
    case invalidInput                   // If the value cannot be encoded as NSData
    case operationUnimplemented         // -4 | errSecUnimplemented
    case invalidParam                   // -50 | errSecParam
    case memoryAllocationFailure        // -108 | errSecAllocate
    case trustResultsUnavailable        // -25291 | errSecNotAvailable
    case authFailed                     // -25293 | errSecAuthFailed
    case duplicateItem                  // -25299 | errSecDuplicateItem
    case itemNotFound                   // -25300 | errSecItemNotFound
    case serverInteractionNotAllowed    // -25308 | errSecInteractionNotAllowed
    case decodeError                    // - 26275 | errSecDecode
    case unknown(Int)                   // Another error code not defined
}

class SecureKeychain {
    class func string(forKey key: String) throws -> String? {
        let loadQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let resultCode = withUnsafeMutablePointer(to: &result) { (pointer) in
            SecItemCopyMatching(loadQuery as CFDictionary, pointer)
        }
        
        if let error = SecureKeychain.mapResultCode(resultCode: resultCode) {
            throw error
        }
        
        guard let resultValue = result as? Data, let keyValue = String(data: resultValue, encoding: .utf8) else {
            return nil
        }
        
        return keyValue
    }
    
    class func setString(_ value: String, forKey key: String) throws {
        guard let valueData = value.data(using: .utf8) else {
            throw KeychainError.invalidInput
        }
        
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: valueData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let resultCode: OSStatus = SecItemAdd(addQuery as CFDictionary, nil)
        
        if let error = SecureKeychain.mapResultCode(resultCode: resultCode) {
            switch error {
            case .duplicateItem:
                // Try to update the item instead
                let updateQuery: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: key
                ]
                let updateAttributes: [String: Any] = [
                    kSecValueData as String: valueData
                ]
                
                if SecItemCopyMatching(updateQuery as CFDictionary, nil) == noErr {
                    let updateResult = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
                    
                    if let error = SecureKeychain.mapResultCode(resultCode: updateResult) {
                        throw error
                    }
                }
                else {
                    throw KeychainError.itemNotFound
                }
                
            default:
                throw error
            }
        }
    }
    
    class func removeObject(forKey key: String) throws {
        let removeQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let resultCode = SecItemDelete(removeQuery as CFDictionary)
        
        if let error = SecureKeychain.mapResultCode(resultCode: resultCode) {
            throw error
        }
    }
    
    fileprivate class func mapResultCode(resultCode: OSStatus) -> KeychainError? {
        switch resultCode {
        case 0:
            return nil
        case -4:
            return .operationUnimplemented
        case -50:
            return .invalidParam
        case -108:
            return .memoryAllocationFailure
        case -25291:
            return .trustResultsUnavailable
        case -25293:
            return .authFailed
        case -25299:
            return .duplicateItem
        case -25300:
            return .itemNotFound
        case -25308:
            return .serverInteractionNotAllowed
        case -26275:
            return .decodeError
        default:
            return .unknown(resultCode.hashValue)
        }
    }
}
