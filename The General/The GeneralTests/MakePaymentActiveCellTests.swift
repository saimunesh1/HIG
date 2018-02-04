//
//  MakePaymentActiveCellTests.swift
//  The GeneralTests
//
//  Created by Irvine, Lee (US - Seattle) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import XCTest
@testable import The_General

class MakePaymentActiveCellTests: XCTestCase {
    var manager: MakePaymentCellManager!
    override func setUp() {
        super.setUp()
        
        self.manager = MakePaymentCellManager()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEnableSplitPayMode() {
        manager.enableSplitPay(numberOfPayments: 5)
        
        let result1 = manager.numberOfSplitPaymentCells()
        XCTAssertTrue(result1 == 5)
        
        manager.enableSinglePay()
        
        let result2 = manager.numberOfSplitPaymentCells()
        XCTAssertTrue(result2 == 0)
    }
    
    func testAddPaymentMethod() {
        manager.enableSplitPay(numberOfPayments: 5)
        manager.addSplitPaymentCell()
        
        let result = manager.numberOfSplitPaymentCells()
        XCTAssertTrue(result == 6)
    }
    
}
