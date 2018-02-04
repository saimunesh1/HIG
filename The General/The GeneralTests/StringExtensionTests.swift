//
//  StringExtensionTests.swift
//  The GeneralTests
//
//  Created by Hopkinson, Todd (US - Denver) on 1/18/18.
//  Copyright © 2018 The General. All rights reserved.
//

import XCTest
@testable import The_General

class StringExtensionTests: XCTestCase {
    
    func testEmptyExesWithLast4() {
        XCTAssertEqual("".replaceEachCharacterWithXSaveLast4Digits(), "")
    }
    
    func testExesWithLast4() {
        XCTAssertEqual("ABCD1234".replaceEachCharacterWithXSaveLast4Digits(), "XXXX1234")
        XCTAssertEqual("0987654321ABCD1234".replaceEachCharacterWithXSaveLast4Digits(), "XXXXXXXXXXXXXX1234")
        XCTAssertEqual("1234".replaceEachCharacterWithXSaveLast4Digits(), "1234")
        XCTAssertEqual("12345".replaceEachCharacterWithXSaveLast4Digits(), "X2345")
        XCTAssertNotEqual("12345678".replaceEachCharacterWithXSaveLast4Digits(), "12345678")
    }
    
}
