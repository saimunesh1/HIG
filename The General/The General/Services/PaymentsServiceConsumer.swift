//
//  PaymentsServiceConsumer.swift
//  The General
//
//  Created by Derek Bowen on 10/9/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

class PaymentsServiceConsumer {    
    let serviceManager = ServiceManager.shared
    
    typealias GetDueDetailsClosure = (() throws -> PaymentsGetDueDetailsResponse) -> Void
    typealias GetSavedPaymentMethodsClosure = (() throws -> [PaymentMethodResponse]) -> Void
    typealias AddPaymentMethodClosure = (() throws -> Void) -> Void
    typealias UpdatePaymentMethodClosure = (() throws -> Void) -> Void
    typealias DeletePaymentMethodClosure = (() throws -> Void) -> Void
    typealias GenerateTokenClosure = (() throws -> String) -> Void
    typealias MakePaymentClosure = (() throws -> Void) -> Void
    typealias SchedulePaymentClosure = (() throws -> Void) -> Void
    
    enum PaymentsErrorType: Error {
        case noToken
    }
    
    /// Get's details about the user's policy payment information.
    ///
    /// - Parameters:
    ///   - policyNumber: Account holder's policy number
    ///   - completion: Completion handler
    func getDueDetails(forPolicy policyNumber: String, completion: @escaping GetDueDetailsClosure) {
 let request = self.serviceManager.request(type: .get, path: "/rest/payment/getDueDetails/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                guard let json = response.jsonObject,
					let responseData = (json["data"] as? [String: Any])?["response"] as? [String: AnyObject] else {
					completion({ throw JSONErrorType.parsingError })
					return
				}
				let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
				let responseModel = try JSONDecoder.shared.decode(PaymentsGetDueDetailsResponse.self, from: jsonData)
				completion({ return responseModel })
            } catch {
                completion({ throw error })
            }
        }
    }
    
    /// Get saved payment methods on the user's account.
    ///
    /// - Parameters:
    ///   - policyNumber: Account holder's policy number
    ///   - completion: Completion handler
    func getSavedPaymentMethods(forPolicy policyNumber: String, completion: @escaping GetSavedPaymentMethodsClosure) {
        let request = self.serviceManager.request(type: .get, path: "/rest/payment/listSavedPaymentMethods/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                
                if let json = response.jsonObject, let responseData = json["data"] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: responseData as Any, options: [])
                        let responseModel = try JSONDecoder.shared.decode([PaymentMethodResponse].self, from: jsonData)
                        completion({ return responseModel })
                    }
                    catch let error {
                        completion({ throw error })
                    }
                }
            }
            catch let error {
                completion({ throw error })
            }
        }
    }

    /// Add a credit/debit card to the available payment methods
    ///
    /// - Parameters:
    ///   - request: Request object containing the credit card details
    ///   - completion: Completion handler
    func addCreditCard(request: AddCardRequest, completion: @escaping AddPaymentMethodClosure) {

        let requestBody: [String: Any] = [
            "policyNumber": request.policyNumber,
            "firstName": request.firstName,
            "lastName": request.lastName,
            "cardNumber": request.cardNumber,
            "month": request.month,
            "year": request.year,
            "street": request.address?.street ?? "",
            "city": request.address?.city ?? "",
            "state": request.address?.state ?? "",
            "zip": request.address?.zip ?? "",
            "preferred": request.preferred,
            "saveForFuture": request.saveForFuture,
            "label": request.label ?? ""
        ]

        let request = self.serviceManager.request(type: .post, path: "/rest/payment/card/add", headers: nil, body: requestBody)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                _ = try innerClosure()
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Update credit/debit card details
    ///
    /// - Parameters:
    ///   - request: Request object containing the credit card details
    ///   - completion: Completion handler
    func updateCreditCard(request: UpdateCardRequest, completion: @escaping UpdatePaymentMethodClosure) {

        var requestBody: [String: Any] = [
            "policyNumber": request.policyNumber,
            "firstName": request.firstName ?? "",
            "lastName": request.lastName ?? "",
            "street": request.address?.street ?? "",
            "city": request.address?.city ?? "",
            "state": request.address?.state ?? "",
            "zip": request.address?.zip ?? "",
            "preferred": request.preferred,
            "label": request.label ?? ""
        ]

        if let cardNumber = request.cardNumber {
            requestBody["cardNumber"] = cardNumber
        }
        if let month = request.month {
            requestBody["month"] = month
        }
        if let year = request.year {
            requestBody["year"] = year
        }

        let path = "/rest/payment/card/update/" + "\(request.id)"
        let request = self.serviceManager.request(type: .put, path: path, headers: nil, body: requestBody)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                _ = try innerClosure()
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Delete credit/debit card
    ///
    /// - Parameters:
    ///   - request: Request object containing the credit card details
    ///   - completion: Completion handler
    func deleteCreditCard(request: DeleteCardRequest, completion: @escaping DeletePaymentMethodClosure) {
        let path = "/rest/payment/card/delete"
        let body = try? JSONEncoder().encode(request)
        let request = self.serviceManager.request(type: .put, path: path, headers: nil, body: body)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                _ = try innerClosure()
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Add a bank account to the available payment methods
    ///
    /// - Parameters:
    ///   - request: Request object containing the bank account details
    ///   - completion: Completion handler
    func addBankAccount(request: AddBankAccountRequest, completion: @escaping AddPaymentMethodClosure) {

        let requestBody: [String: Any] = [
            "policyNumber": request.policyNumber,
            "routingNumber": request.routingNumber,
            "accountNumber": request.accountNumber,
            "preferred": request.preferred,
            "saveForFuture": request.saveForFuture,
            "label": request.label ?? ""
        ]

        let request = self.serviceManager.request(type: .post, path: "/rest/payment/bankAccount/add", headers: nil, body: requestBody)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                _ = try innerClosure()
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Update bank account details
    ///
    /// - Parameters:
    ///   - request: Request object containing the bank account details
    ///   - completion: Completion handler
    func updateBankAccount(request: UpdateBankAccountRequest, completion: @escaping UpdatePaymentMethodClosure) {

        let requestBody: [String: Any] = [
            "policyNumber": request.policyNumber,
            //"routingNumber": request.routingNumber,
            //"accountNumber": request.accountNumber,
            "preferred": request.preferred,
            "label": request.label ?? ""
        ]

        let path = "/rest/payment/bankAccount/update/" + "\(request.id)"
        let request = self.serviceManager.request(type: .put, path: path, headers: nil, body: requestBody)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                _ = try innerClosure()
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Delete bank account
    ///
    /// - Parameters:
    ///   - request: Request object containing the bank account details
    ///   - completion: Completion handler
    func deleteBankAccount(request: DeleteBankAccountRequest, completion: @escaping DeletePaymentMethodClosure) {
        let path = "/rest/payment/bankAccount/delete"
        let body = try? JSONEncoder().encode(request)
        let request = self.serviceManager.request(type: .put, path: path, headers: nil, body: body)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                _ = try innerClosure()
                completion({ /* Success */ })
            }
            catch {
                completion({ throw error })
            }
        }
    }

    /// Generates a single use token for a credit card
    ///
    /// - Parameters:
    ///   - request: Request object containing credit card details
    ///   - completion: Completion handler, returns the generated token
    func generateToken(request: GenerateTokenRequest, completion: @escaping GenerateTokenClosure) {
        do {
            let jsonData = try JSONEncoder().encode(request)
            let request = self.serviceManager.request(type: .post, path: "/rest/payment/card/generateToken", headers: nil, body: jsonData)
            
            self.serviceManager.async(request: request) { (innerClosure) in
                do {
                    let response = try innerClosure()
                    
                    guard let json = response.jsonObject, let responseData = json["data"] as? [String: Any] else {
                        completion({ throw JSONErrorType.parsingError })
                        return
                    }
                    
                    if let token = responseData["tokenNumber"] as? String {
                        completion({ return token })
                    }
                    else {
                        completion({ throw PaymentsErrorType.noToken })
                    }
                }
                catch {
                    completion({ throw error })
                }
            }
        }
        catch {
            completion({ throw error })
        }
    }
    
    /// Make a payment for the user's policy
    ///
    /// - Parameters:
    ///   - request: Request object containing the payment details
    ///   - completion: Completion handler
    func makePayment(request: MakePaymentRequest, completion: @escaping MakePaymentClosure) {
        do {
            
            let paymentRequestType = request.type
            switch paymentRequestType {
            case .bankAccount:
                AnalyticsManager.track(event: .paymentsECheckInitiated)
            case .card:
                AnalyticsManager.track(event: .paymentsCCDebitInitiated)
            }
            
            let jsonData = try JSONEncoder().encode(request)
            let request = self.serviceManager.request(type: .post, path: "/rest/payment/makePayment", headers: nil, body: jsonData)
            
            self.serviceManager.async(request: request) { (innerClosure) in
                do {
                    _ =  try innerClosure()
                    
                    switch paymentRequestType {
                        case .bankAccount:
                        AnalyticsManager.track(event: .paymentsECheckCompleted)
                        case .card:
                        AnalyticsManager.track(event: .paymentsCCDebitCompleted)
                    }
                    
                    completion({ /* Success */ })
                }
                catch {
                    
                    switch paymentRequestType {
                    case .bankAccount:
                        AnalyticsManager.track(event: .paymentsECheckDeclined)
                    case .card:
                        AnalyticsManager.track(event: .paymentsCCDebitDeclined)
                    }
                    
                    completion({ throw error })
                }
            }
        }
        catch {
            completion({ throw error })
        }
    }

    
    /// Schedule a payment for the user's policy
    ///
    /// - Parameters:
    ///   - request: SchedulePaymentRequest
    ///   - completion: Completion handler, same type as makePayment handler for improved portability
    func schedulePayment(request: SchedulePaymentRequest, completion: @escaping SchedulePaymentClosure) {
        do {
            let jsonData = try JSONEncoder().encode(request)
            let request = self.serviceManager.request(type: .post, path: "/rest/schedulePayment/schedulePayment", headers: nil, body: jsonData)
            
            self.serviceManager.async(request: request) { (innerClosure) in
                do {
                    _ =  try innerClosure()
                    completion({ /* Success */ })
                }
                catch {
                    completion({ throw error })
                }
            }
        }
        catch {
            completion({ throw error })
        }
    }

    
    
    private class PayNearMeConfiguration {
        
        let kDigitalSignature = "80cd77d90089db94"
        
        func item(_ type: Item) -> String? {
            
            if type == .digitalSignature {
                return kDigitalSignature
            }
            
            return self.configuration?[type.rawValue]
        }
        
        enum Item:String {
            case siteIdentifier = "Site Identifier"
            case siteVersion = "Site Version"
            case baseURL = "Base URL"
            case digitalSignature = "Digital Signature"
        }
        
        private typealias ConfigurationType = [String: String]
        
        private lazy var configuration: ConfigurationType? = {
            guard let url = Bundle.main.url(forResource: "PayNearMe-Info", withExtension: "plist"), let data = try? Data(contentsOf: url), let configuration = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? ConfigurationType else {
                return nil
            }
            
            return configuration
        }()
    }
    
    
    //MARK: - Pay Near Me
    func activatePayNearMe(withAmount amount: Decimal, success: @escaping (_ url: URL) -> (), failure: ((_ error: Error)->())? = nil) throws {
        
        let configuration = PayNearMeConfiguration()
        
        guard let kSiteVersion = configuration.item(.siteVersion), let kSiteIdentifier = configuration.item(.siteIdentifier), let kBaseURL = configuration.item(.baseURL), let kDigitalSignature = configuration.item(.digitalSignature) else {
            throw PayNearMeIssue.other
        }
        
        guard let policyNumber = SessionManager.policyNumber else {
            throw PayNearMeIssue.missingPolicyNumber
        }
        
        enum EndPoint:String {
            case findOrders = "find_orders"
            case createOrder = "create_order"
        }
        
        enum Parameter:String {
            case siteCustomerIdentifier = "site_customer_identifier"
            case timestamp = "timestamp"
            case version = "version"
            case siteIdentifier = "site_identifier"
            case orderAmount = "order_amount"
            case orderCurrency =  "order_currency"
            case orderType = "order_type"
        }
        
        typealias Value = String
        
        func getUrl(forEndpoint endpoint: EndPoint, andParameters parameters: [Parameter: Value]? = nil) -> String {
            
            var mutableParameters: [Parameter: Value] = {
                return parameters ?? [:]
            }()
            
            let epochTimestamp = Int(Date().timeIntervalSince1970)
            
            mutableParameters[.timestamp] = Value(epochTimestamp)
            mutableParameters[.version] = kSiteVersion
            mutableParameters[.siteIdentifier] = kSiteIdentifier
            
            let parametersInOrder: [(Parameter, Value)] = mutableParameters.sorted { (first, second) -> Bool in
                return first.key.rawValue < second.key.rawValue
            }
            
            var url: String = kBaseURL + endpoint.rawValue
            for (index, parameter) in parametersInOrder.enumerated() {
                if index == 0 {
                    url += "?"
                }
                
                url += parameter.0.rawValue + "=" + parameter.1
                
                if index < parametersInOrder.count {
                    url += "&"
                }
            }
            
            // Create MD5 hashed string of parameters and values
            var hashString = ""
            for parameter in parametersInOrder {
                hashString += parameter.0.rawValue + parameter.1
            }
            
            // Add PayNearMe digital signature
            hashString += kDigitalSignature
            
            // Add MD5 concatenated hash as paramter to URL
            url += "&signature=\(hashString.md5)"
            
            return url
        }
        
        
        func createPaymentAndFetchURL() {
            
            let createPaymentURL = getUrl(forEndpoint: .createOrder, andParameters: [.siteCustomerIdentifier: policyNumber, .orderAmount: amount.description, .orderCurrency: "USD", .orderType: "any"])
            
            self.serviceManager.startRequest(type: .post, path: createPaymentURL, headers: [:], body: nil) { innerClosure in
                
                do {
                    let response = try innerClosure()
                    guard let dictionary = response.xmlObject as? [String: Any], let orderTrackingURLs = dictionary["order order_tracking_url"] as? [String], let orderTrackingURLString = orderTrackingURLs.first, let url = URL(string: orderTrackingURLString) else {
                        failure?(XMLErrorType.parsingError)
                        return
                    }
                    
                    success(url)
                    
                } catch {
                    failure?(error)
                }
            }
        }
        
        let findOrdersURL = getUrl(forEndpoint: .findOrders, andParameters: [.siteCustomerIdentifier: policyNumber])
        
        self.serviceManager.startRequest(type: .get, path: findOrdersURL, headers: [:], body: nil) { innerClosure in
            
            do {
                let response = try innerClosure()
                guard let dictionary = response.xmlObject as? [String: Any] else {
                    failure?(XMLErrorType.parsingError)
                    return
                }
                
                if let _ = dictionary["error description"] as? [String] {
                    createPaymentAndFetchURL()
                    return
                }
                
                // *********
                // Look for existing orders
                // *********
                
                let orderTrackingURLs = dictionary["order order_tracking_url"] as? [String]
                let orderStatii = dictionary["order order_status"] as? [String]
                let orderTypes = dictionary["order order_type"] as? [String]
                let orderExpirationDates = dictionary["order_expiration_date"] as? [String]
                let orderAmounts = dictionary["order_amount"] as? [String]
                
                if let statii = orderStatii {
                    checkStatii: for (index, status) in statii.enumerated() where status.caseInsensitiveContains("open") {
                        
                        var type: String?
                        if let types = orderTypes, types.indices.contains(index) {
                            type = types[index]
                        }
                        
                        var expirationDate: String?
                        if let expirationDates = orderExpirationDates, expirationDates.indices.contains(index) {
                            expirationDate = expirationDates[index]
                        }
                        
                        var amount: String?
                        if let amounts = orderAmounts, amounts.indices.contains(index) {
                            amount = amounts[index]
                        }
                        
                        var trackingURL: URL?
                        if let trackingURLs = orderTrackingURLs, trackingURLs.indices.contains(index) {
                            trackingURL = URL(string: trackingURLs[index] )
                        }
                        
                        let typeIsAny = type != nil && type!.caseInsensitiveContains("any")
                        let expirationDateNotSet = expirationDate == nil || expirationDate!.isEmpty
                        let orderAmountNotSet = amount == nil || amount!.isEmpty
                        let trackingURLFound = trackingURL != nil
                        
                        let additionalRequirements: [Bool] = [typeIsAny, expirationDateNotSet, orderAmountNotSet, trackingURLFound]
                        
                        for requirementMet in additionalRequirements where !requirementMet {
                            continue checkStatii
                        }
                        
                        // Found existing order
                        success(trackingURL!)
                        return
                    }
                }
                
                // No existing order found, create new payment
                createPaymentAndFetchURL()
                
                
            } catch {
                failure?(error)
            }
        }
    }
}
