//
//  SignInTests.swift
//  The GeneralTests
//
//  Created by Irvine, Lee (US - Seattle) on 11/29/17.
//  Copyright © 2017 The General. All rights reserved.
//
@testable import The_General
import XCTest

class SignInTests: XCTestCase {
    var expectation: XCTestExpectation!
    var signInService: SignInServiceConsumer!
    
    override func setUp() {
        super.setUp()
        
        self.signInService = SignInServiceConsumer()
        self.expectation = XCTestExpectation(description: "wait for api response")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDecodeGetTokenJson() {
        let json = """
        {
            "success": true,
            "message": "Login Success",
            "data": {
                "policyNumber": null,
                "quotes": [
                "1023345567",
                "999888",
                "999777"
                ],
                "tgt": "TGT-216-ZqjCyTmTWXPwXVB3kBgX3xqcHWahCoUvAZbdIgiRKiMqAqU8bCq1G8aJdfkWTCvgZ3U-pgaccmstv1"
            },
            "errors": null
        }
        """
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: json.data(using: .utf8)!, options: []) as AnyObject
            
            let decoder = SignInDecoder()
            let result = try decoder.decodeGetTokenResponse(jsonObject)
            
            XCTAssertNotNil(result.tgt)
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testSignInSuccess() {
        let pnum = "999888"
        let pw = "asdfghjkl;"
        
        signInService.getToken(emailOrPolicy: pnum, password: pw) { (innerClosure) in
            do {
                let result = try innerClosure()
                let token = result.tgt
                
                XCTAssertNotNil(token)
                self.expectation.fulfill()
                
            } catch let error {
                XCTFail(error.localizedDescription)
                self.expectation.fulfill()
            }
        }
        
        self.wait(for: [expectation], timeout: 5)
    }
    
    func testPasswordReset() {
        let pnum = "999888"
        signInService.requestPasswordReset(emailOrPolicy: pnum) { (innerClosure) in
            do {
                try innerClosure()
                self.expectation.fulfill()
            } catch let error {
                XCTFail(error.localizedDescription)
                self.expectation.fulfill()
            }
        }
        
        self.wait(for: [expectation], timeout: 5)
    }


}
