//
//  SessionManagerTests.swift
//  The GeneralTests
//
//  Created by Irvine, Lee (US - Seattle) on 11/29/17.
//  Copyright © 2017 The General. All rights reserved.
//

@testable import The_General
import XCTest

class SessionManagerTests: XCTestCase {
    
    func testSetUsername() {
        SessionManager.username = "Lee"
        
        XCTAssertNotNil(SessionManager.username)
        XCTAssertEqual(SessionManager.username, "Lee")
    }
    
    func testClearUsername() {
        SessionManager.username = nil
        
        XCTAssertNil(SessionManager.username)
    }
    
}
