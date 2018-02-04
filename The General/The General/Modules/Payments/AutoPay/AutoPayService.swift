//
//  AutoPayService.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 1/18/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - Service
//--------------------------------------------------------------------------

class AutoPayService {
    
    enum EnrollError:Error {
        case invalidPayment
        case couldNotEnroll
    }
    
    typealias EnrollResponseClosure = (_ success: Bool) -> ()
    
    func enroll(usingPayment payment: PaymentMethodResponse, forPolicyNumber policyNumber: String, completion: @escaping EnrollResponseClosure) throws {
        
        var data: Data!
        
        do {
            if !payment.saveForLater { // This is a new payment method
                if let card = MakePaymentCardInfo(paymentMethodResponse: payment) {
                    data = try JSONEncoder().encode(card)
                    
                } else if let bankAccount = MakePaymentBankAccountInfo(paymentMethodResponse: payment) {
                    data = try JSONEncoder().encode(bankAccount)
                    
                } else {
                    throw EnrollError.invalidPayment
                }
                
            } else { // Previously saved card which already has ID
                let newCard: [String: Any] = ["type": "Card", "card": ["cardId": payment.id]]
                data = try JSONSerialization.data(withJSONObject: newCard, options: .prettyPrinted)
            }
            
        } catch {
            throw EnrollError.invalidPayment
        }
        
        
        let request = self.serviceManager.request(type: .post, path: "/rest/autoDebit/enroll/\(policyNumber)", headers: nil, body: data)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                
                guard let json = response.jsonObject else {
                    completion(false)
                    return
                }
                
                guard let success = json["success"] as? Bool, success else {
                    completion(false)
                    return
                }
                
                completion(true)
                
            } catch {
                completion(false)
            }
        }
    }
    
    enum UnregisterError:Error {
        case couldNotComplete
    }
    
    typealias UnregisterResponseClosure = (_ success: Bool) -> ()
    
    func unregister(forPolicyNumber policyNumber: String, completion: @escaping UnregisterResponseClosure) throws {
        
        let request = self.serviceManager.request(type: .delete, path: "/rest/autoDebit/cancel/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                
                guard let json = response.jsonObject as? [String: Any] else {
                    completion(false)
                    return
                }
                
                guard let success = json["success"] as? Bool, success else {
                    completion(false)
                    return
                }
                
                completion(true)
                
            } catch {
                completion(false)
            }
        }
    }
    
    typealias HistoryResponseClosure = (() throws -> [HistoryItem]) -> ()
    
    func fetchHistory(forPolicy policyNumber: String, completion: @escaping HistoryResponseClosure) {
        
        let request = self.serviceManager.request(type: .get, path: "/rest/payment/paymentschedule/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                
                guard let json = response.jsonObject else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
                
                let responseModel = try JSONDecoder.shared.decode(Response.self, from: jsonData)
                
                guard let items = responseModel.data?.invoices else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                
                completion({ return items })
                
            } catch {
                completion({ throw error })
            }
        }
    }
    
    
    //MARK: - Private
    fileprivate let serviceManager = ServiceManager.shared
    
    struct Response: Decodable {
        var data: HistoryData?
    }
    
    struct HistoryData: Decodable {
        var invoices: [HistoryItem]
    }
    
    struct HistoryItem: Decodable {
        let issuedOn: String?
        let dueOn: String?
        let amount: CoercingDecimal?
    }
}
