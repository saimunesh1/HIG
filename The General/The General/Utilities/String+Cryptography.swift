//
//  String+Cryptography.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

//==============================================================================
// MARK: - Cryptography
//==============================================================================

extension String {
    
    var md5: String {
        get {
            let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
            var digest = Array<UInt8>(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5_Init(context)
            CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
            CC_MD5_Final(&digest, context)
            context.deallocate(capacity: 1)
            var hexString = ""
            for byte in digest {
                hexString += String(format:"%02x", byte)
            }
            
            return hexString
        }
    }
}
