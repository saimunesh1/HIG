//
//  IDCardServiceConsumer.swift
//  The General
//
//  Created by Hopkinson, Todd (US - Denver) on 1/4/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

typealias IDCardInfoClosure = (() throws -> IDCardInfoResponse) -> Void

class IDCardServiceConsumer {
    
    let serviceManager = ServiceManager.shared
    
    /// Request the ID Cards info
    ///
    /// - Parameters:
    ///  - policyNumber: Policy number
    ///  - completion: Completion handler
    func getIDCardInfo(policyNumber: String, completion: @escaping IDCardInfoClosure) {
        let request = self.serviceManager.request(type: .get, path: "/rest/IDCard/listDriverAndVehicles/\(policyNumber)", headers: nil, body: nil)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                if let jsonData = response.data {
                    var responseModel = try JSONDecoder().decode(IDCardInfoResponse.self, from: jsonData)
                    responseModel.jsonDataCacheBase64String = jsonData.base64EncodedString()
                    completion({ return responseModel })
                }
            } catch let error {
                completion({ throw error })
            }
        }
    }
    
}
