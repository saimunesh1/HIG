//
//  DashboardServiceConsumer.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation
import AirshipKit

var inboxMessageList: UAInboxMessageList?

class DashboardServiceConsumer {
    let serviceManager = ServiceManager.shared
    
    typealias GetDashboardInfoClosure = (() throws -> DashboardResponse) -> Void
    typealias GetFeaturedPromoClosure = (() throws -> GetFeaturedPromoResponse?) -> Void
    
    /// Gets a summary of information to display on the dashboard
    ///
    /// - Parameters:
    ///   - policyNumber: Policy number to get dashboard summary for
    ///   - completion: Completion handler, returns DashboardResponse
    func getDashboardInfo(forPolicy policyNumber: String?, completion: @escaping GetDashboardInfoClosure) {
        let requestBody: [String: String?] = [
            "policyNumber": policyNumber,
            "ticketGrantingTicket": SessionManager.accessToken
        ]

        let request = self.serviceManager.request(type: .post, path: "/rest/dashboard/retrieveDashboard", headers: nil, body: requestBody)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                        completion({ throw JSONErrorType.parsingError })
                        return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode(DashboardResponse.self, from: jsonData)
                completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }
    
    func getFeaturedPromo(completion: @escaping GetFeaturedPromoClosure) {
        guard let channelId = UAirship.push().channelID,
              let username = UAirship.inboxUser().username else {
            completion({ return nil })
            return
        }
        
        let requestBody: [String: String?] = [
            "Authorization": UAUtils.userAuthHeaderString(),
            "X-UA-Channel-ID": channelId
        ]

        let url = URL(string: "https://device-api.urbanairship.com/api/user/\(username)/messages/")!
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 30.0)
        
        request.httpMethod = "GET"
        
        for (key, value) in requestBody {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        ServiceManager().async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject, let responseData = json["messages"] as? [[String: Any]] else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                let responseModel = try JSONDecoder.shared.decode([GetFeaturedPromoResponse].self, from: jsonData)

                if let promo = responseModel.first(where: { $0.type == "promo"}) {
                    completion({ return promo })
                } else {
                    completion({ return nil })
                }
            } catch {
                completion({ throw error })
            }
        }
    }
}
