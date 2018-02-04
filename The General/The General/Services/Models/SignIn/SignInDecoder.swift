//
//  SignInJsonDecoder.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 12/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class SignInDecoder {
    func decodeGetTokenResponse(_ jsonObject: AnyObject?) throws -> GetTokenResponse {
        guard let json = jsonObject,
            let responseData = (json["data"] as? [String: Any]) else {
                throw ServiceErrorType.invalidResponse
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
        let response = try JSONDecoder.shared.decode(GetTokenResponse.self, from: jsonData)
        
        return response
    }

}
