//
//  PhoneNumberFormatterTests.swift
//  The GeneralTests
//
//  Created by Blanco, John (US - Denver) on 12/20/17.
//  Copyright © 2017 The General. All rights reserved.
//

@testable import The_General
import XCTest

class PhoneNumberFormatterTests: XCTestCase {
    
    func testEmpty() {
        XCTAssertEqual(NumberFormatter.phoneNumber(from: ""), "")
    }

    func testTen() {
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "1234567890"), "(123) 456-7890")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "(123) 456-7890"), "(123) 456-7890")
    }

    func testEleven() {
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "11234567890"), "1 (123) 456-7890")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "1-123-456-7890"), "1 (123) 456-7890")
    }

    func testMiscountedDigitRejects() {
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "1"), "")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "12"), "")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "123"), "")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "1234"), "")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "12345"), "")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "123456"), "")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "12345678"), "")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "123456789"), "")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "123456789012"), "")
    }

    func testInvalidCharacterRejects() {
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "/"), "")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: " "), "")
        XCTAssertEqual(NumberFormatter.phoneNumber(from: "..."), "")
    }
}
