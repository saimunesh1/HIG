//
//  ServiceManager.swift
//  The General
//
//  Created by Derek Bowen on 10/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum ServiceErrorType: Error {
    case invalidResponse
    case unsuccessful(message: String?, errors: [String]?)
    case serverError(statusCode: Int)
    case unhandledStatusCode(statusCode: Int)
}

enum JSONErrorType: Error {
    case parsingError
    case missingElement
}

enum XMLErrorType: Error {
    case parsingError
    case missingElement
}

struct ServiceResponse {
    let jsonObject: AnyObject?
    let xmlObject: AnyObject?
    let data: Data?
    let httpResponse: HTTPURLResponse
}

typealias ServiceManagerAsyncCompletion = (() throws -> ServiceResponse) -> Void

class ServiceManager: NSObject {
    static let shared = ServiceManager()
    
    public let baseURL: String = {
        switch SettingsManager.environment {
        case .internalDevelopment:
            return "https://ws3.pgactest.com/NativeMobileServiceV2"
        case .development:
            return "https://ws.pgac.com/NativeMobileServiceV2Test"
        case .mock:
            return "http://localhost:3000"
        case .production:
            return "https://ws.pgac.com/NativeMobileServiceV2"
        }
    }()
    
    public let webContentBaseURL: String = {
        switch SettingsManager.environment {
        case .internalDevelopment, .development:
            return "https://usertesting.pgac.com"
        case .mock:
            return "http://localhost:3000"
        case .production:
            return "https://www.thegeneral.com"
        }
    }()
	
	public let fonoloProfileSid: String = {
		switch SettingsManager.environment {
		case .internalDevelopment, .development, .mock:
			return "CP64295f3be11645dab85715eb55960b57"
		case .production:
			return "CPaa3373159ba23d4e2462396a50b7f9ff"
		}
	}()
	
	public let fonoloOptionSalesSid: String = {
		switch SettingsManager.environment {
		case .internalDevelopment, .development, .mock:
			return "COaaad4c9123504953ead221a9d058b9f0"
		case .production:
			return "CO8c145b6ee35da75a19a1b8edc1e8d02d"
		}
	}()
	
	public let fonoloOptionCustomerServiceSid: String = {
		switch SettingsManager.environment {
		case .internalDevelopment, .development, .mock:
			return "COaaad4c9123504953ead221a9d058b9f0"
		case .production:
			return "CO15b3e61e2605be6d1442a7a51836d2c4"
		}
	}()
    
    public let esignUrl: String = {
        switch SettingsManager.environment {
        case .internalDevelopment, .development, .mock:
            return "https://www1.thegeneraltest.com"
        case .production:
            return "https://www.thegeneral.com"
        }
    }()
	
    private var urlSession: URLSession {
        let configuration = URLSessionConfiguration.default
        if SettingsManager.environment == .development {
            configuration.timeoutIntervalForRequest = 60
        }
        return URLSession(configuration: configuration)
    }
    
    private var standardHeaders: [String: String] {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json",
        ]
    }
    
    var authenticationHeaders: [String: String] {
        guard let accessToken = SessionManager.accessToken else {
            return [:]
        }
        
        return [
            "tgt": accessToken
        ]
    }
    
    // ********* Discussion:
    // `path` can be a full URL string representing the entire path, or just the last path components which will be added to the "base URL"
    //
    func startRequest(type: RequestType, path: String, headers: [String: String]?, body: Any?, complete: @escaping ServiceManagerAsyncCompletion) {
        
        let request = self.request(type: type, path: path, headers: headers, body: body)
        self.async(request: request, completion: complete)
    }
    
    // ********* Discussion:
    // `path` can be a full URL string representing the entire path, or just the last path components which will be added to the "base URL"
    //
    func request(type: RequestType, path: String, headers: [String: String]?, body: Any?) -> URLRequest {
        let urlString: String!
        
        if path.prefix(4) == "http" {
            urlString = path
            
        } else {
            urlString = self.baseURL.appending(path)
        }
        
        let url = URL(string: urlString)!

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        request.httpMethod = type.rawValue
        
        // Set standard headers
        for (key, value) in self.standardHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set authentication headers
        for (key, value) in self.authenticationHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set request headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Add body to the request
        if let body = body {
            // Raw Data
            if let body = body as? Data {
                request.httpBody = body
            }
            // Objects, try to JSON serialize
            else {
                do {
                    let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
                    request.httpBody = bodyData
                }
                catch {
                    request.httpBody = nil
                }
            }
        }
        
        return request
    }
    
    func async(request: URLRequest, completion: @escaping ServiceManagerAsyncCompletion) {
        ServiceManager.log(request)
        
        let task = self.urlSession.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion({ throw error! })
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion({ throw ServiceErrorType.invalidResponse })
                }
                return
            }
            
            ServiceManager.log(response, withBody: data)
            
            switch response.statusCode {
            case 200..<300, 400..<500:
                if let data = data, !data.isEmpty {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        
                        // Check if success property exists, and is false
                        if let json = json as? [String: Any],
                            let success = json["success"] as? Bool, !success {
                            DispatchQueue.main.async {
                                let message = json["message"] as? String ?? ""
                                let errors = json["errors"] as? [String] ?? [""]
                                completion({ throw ServiceErrorType.unsuccessful(message: message, errors: errors) })
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                
                                completion({ return ServiceResponse(jsonObject: json as AnyObject, xmlObject: nil, data: data, httpResponse: response) })
                            }
                        }
                    }
                    catch let error {
                        
                        self.parseXML(fromData: data, complete: { result in
                            
                            DispatchQueue.main.async {
                                
                                guard let xmlResult = result else {
                                    completion({ throw error })
                                    return
                                }
                                
                                completion({ return ServiceResponse(jsonObject: nil, xmlObject: xmlResult as AnyObject, data: nil, httpResponse: response) })
                            }
                        })
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion({ return ServiceResponse(jsonObject: nil, xmlObject: nil, data: nil, httpResponse: response) })
                    }
                }
            case 500..<600:
                DispatchQueue.main.async {
                    completion({ throw ServiceErrorType.serverError(statusCode: response.statusCode) })
                }
            default:
                DispatchQueue.main.async {
                    completion({ throw ServiceErrorType.unhandledStatusCode(statusCode: response.statusCode) })
                }
            }
            
        }
        task.resume()
    }
    
    fileprivate func parseXML(fromData data: Data, complete: @escaping(_ result: [Key: Values]?) -> ()) {
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self
        self.xmlParseCompletion = complete
        xmlParser.parse()
    }
    
    
    //MARK: - XML Parsing
    typealias Key = String
    typealias Values = [String]
    
    fileprivate var lastElement: String?
    fileprivate var result: [Key: Values]?
    fileprivate var xmlParseCompletion: ((_ result: [Key: Values]? )->())?
}


// MARK: - XML Parsing
extension ServiceManager: XMLParserDelegate {
    
    internal func parserDidStartDocument(_ parser: XMLParser) {
        result = [:]
    }
    
    private func addXMLValue(value: String, toKey key: String) {
        var values = result![key]
        if values == nil {
            values = []
        }
        values!.append(value)
        result![key] = values
    }
    
    internal func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        
        self.lastElement = elementName
        
        for (key, value) in attributeDict {
            
            let concatenatedKey = elementName + " " + key
            self.addXMLValue(value: value, toKey: concatenatedKey)
        }
    }
    
    internal func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let lastElement = self.lastElement else {
            return
        }
        
        self.addXMLValue(value: string, toKey: lastElement)
    }
    
    internal func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.lastElement = nil
    }
    
    internal func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        self.lastElement = nil
        self.result = nil
        self.xmlParseCompletion?(nil)
        self.xmlParseCompletion = nil
        
        parser.abortParsing()
    }
    
    internal func parserDidEndDocument(_ parser: XMLParser) {
        self.xmlParseCompletion?(result)
        self.xmlParseCompletion = nil
    }
}


// MARK: - Logging
extension ServiceManager {
    fileprivate class func log(_ request: URLRequest) {
        var message = "--- ServiceManager: Request\n"
        message += "  \(request.httpMethod!) \(request.url!)\n"
        if let headers = request.allHTTPHeaderFields {
            message += "  Headers:\n"
            for header in headers {
                message += "    \(header.key): \(header.value)\n"
            }
        }
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            message += "  Body:\n"
            if let jsonString = ServiceManager.prettyPrintedJSON(fromData: body) {
                message += jsonString + "\n"
            }
            else {
                message += bodyString + "\n"
            }
        }
        message += "\n---\n"
        
        #if DEBUG
        NSLog(message)
        #endif
    }
    
    fileprivate class func log(_ response: HTTPURLResponse, withBody body: Data?) {
        var message = "--- ServiceManager: Response\n"
        message += "  \(response.url!)\n"
        message += "  \(response.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))\n"
        message += "  Headers:\n"
        for header in response.allHeaderFields {
            message += "    \(header.key): \(header.value)\n"
        }
        if let body = body,
           let bodyString = String(data: body, encoding: .utf8) {
            message += "  Body:\n"
            if let jsonString = ServiceManager.prettyPrintedJSON(fromData: body) {
                message += jsonString + "\n"
            }
            else {
                message += bodyString + "\n"
            }
        }
        message += "\n---\n"
        
        #if DEBUG
            NSLog(message)
        #endif
    }
    
    fileprivate class func prettyPrintedJSON(fromData data: Data) -> String? {
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            if let jsonString = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted) {
                return String(data: jsonString, encoding: .utf8)
            }
        }
        
        return nil
    }
}
