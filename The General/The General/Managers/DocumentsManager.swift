//
//  DocumentsManager.swift
//  The General
//
//  Created by Leif Harrison on 12/7/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

class DocumentsManager {
    
    let serviceConsumer = DocumentsServiceConsumer()

    typealias GetHistoricalDocumentInfoClosure = (() throws -> HistoricalDocumentInfoResponse) -> Void
    typealias GetHistoricalDocumentClosure = (() throws -> HistoricalDocumentResponse) -> Void

    /// Request historical document info for the specified policy and document type
    ///
    /// - Parameters:
    ///  - policyNumber: Account holder's policy number
    ///  - docType: Document type being requested
    ///  - completion: Completion handler
    func getHistoricalDocumentInfo(forPolicy policyNumber: String, docType: DocumentType, completion: @escaping GetHistoricalDocumentInfoClosure) {
        self.serviceConsumer.getHistoricalDocumentInfo(forPolicy: policyNumber, docType: docType) { (innerClosure) in
            completion(innerClosure)
        }
    }

    /// Request historical document info for the specified policy and document type
    ///
    /// - Parameters:
    ///  - policyNumber: Account holder's policy number
    ///  - request:Request describing the document being requested
    ///  - completion: Completion handler
    func getHistoricalDocument(forPolicy policyNumber: String, request: HistoricalDocumentRequest, completion: @escaping GetHistoricalDocumentClosure) {
        self.serviceConsumer.getHistoricalDocument(forPolicy: policyNumber, request: request) { (innerClosure) in
            completion(innerClosure)
        }
    }

}
