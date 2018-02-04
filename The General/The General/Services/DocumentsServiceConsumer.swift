//
//  DocumentsServiceConsumer.swift
//  The General
//
//  Created by Leif Harrison on 12/7/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

enum DocumentType: String {
    case currentInvoice = "currentInvoice"
}

class DocumentsServiceConsumer {

    typealias GetHistoricalDocumentInfoClosure = (() throws -> HistoricalDocumentInfoResponse) -> Void
    typealias GetHistoricalDocumentClosure = (() throws -> HistoricalDocumentResponse) -> Void

    let serviceManager = ServiceManager.shared

    /// Request historical document info for the specified policy and document type
    ///
    /// - Parameters:
    ///  - policyNumber: Account holder's policy number
    ///  - docType: Document type being requested
    ///  - completion: Completion handler
    func getHistoricalDocumentInfo(forPolicy policyNumber: String, docType: DocumentType, completion: @escaping GetHistoricalDocumentInfoClosure) {
        let path = "/rest/documents/historicalDocument/info" + "/\(docType.rawValue)" + "/\(policyNumber)"
        let request = self.serviceManager.request(type: .get, path: path, headers: nil, body: nil)
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                if let json = response.jsonObject, let responseData = (json["data"] as? [String: Any]) {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: responseData, options: [])
                        let responseModel = try JSONDecoder.shared.decode(HistoricalDocumentInfoResponse.self, from: jsonData)
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

    /// Request historical document for the specified policyd
    ///
    /// - Parameters:
    ///  - policyNumber: Account holder's policy number
    ///   - request: Request object containing requested document details
    ///   - completion: Completion handler, returns the generated token
    func getHistoricalDocument(forPolicy policyNumber: String, request: HistoricalDocumentRequest, completion: @escaping GetHistoricalDocumentClosure) {
        do {
            let path = "/rest/documents/historicalDocument/pdf" + "/\(policyNumber)"
            let jsonData = try JSONEncoder().encode(request)
            let serviceRequest = self.serviceManager.request(type: .post, path: path, headers: nil, body: jsonData)

            self.serviceManager.async(request: serviceRequest) { (innerClosure) in
                do {
                    let response = try innerClosure()
                    if let json = response.jsonObject, let responseData = (json["data"] as? String) {
                        if let decodedData = Data(base64Encoded: responseData, options:[]) { // , let decodedString = String(data: decodedData, encoding: String.Encoding.utf8)
                            let tempDir =  FileManager.default.temporaryDirectory
                            let destinationURL = tempDir.appendingPathComponent(request.pdfName).appendingPathExtension("pdf")
                            do {
                                try decodedData.write(to: destinationURL, options: .atomic)
                                print("destinationURL = \(destinationURL)")
                            } catch {
                                print(error)
                            }
                            let documentResponse = HistoricalDocumentResponse(documentURL: destinationURL)
                            completion({ return documentResponse })
                        }
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


}
