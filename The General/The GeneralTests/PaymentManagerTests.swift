//
//  PaymentManagerTests.swift
//  The GeneralTests
//
//  Created by Irvine, Lee (US - Seattle) on 1/16/18.
//  Copyright © 2018 The General. All rights reserved.
//
@testable import The_General
import XCTest

class PaymentManagerTests: XCTestCase {
    var paymentsManager: PaymentsManager!

    override func setUp() {
        super.setUp()
        self.paymentsManager = PaymentsManager()
        self.paymentsManager.dueDetails = getDueDetails()
        self.paymentsManager.startMakePaymentSession()
        self.paymentsManager.activeMakePaymentSession?.paymentEntries = []
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScheduledPayment() {
        let expt = XCTestExpectation(description: "wait.for.schedule.pay")
        self.wait(for: [expt], timeout: 5.0)
        
        let card = MakePaymentEntry()
        card.amount = self.paymentsManager.activeMakePaymentSession!.amount
        card.paymentMethod = getPaymentCard()
        
        self.paymentsManager.activeMakePaymentSession?.paymentEntries.append( card )

        paymentsManager.scheduledPaymentDate = Date().addingTimeInterval(3600 * 24 * 29)
        do {
            try paymentsManager.submitScheduledPayment { (success, fail) in
                XCTAssert(success.count > 0 || fail.count > 0)
                expt.fulfill()
            }
        } catch let err {
            XCTFail(err.localizedDescription)
            expt.fulfill()
        }
    }
    
    private func getPaymentCard() -> PaymentMethodResponse! {
        let json = """
        {
            "type": "CARD",
            "id": 212,
            "last4Digits": "0026",
            "routingNumber": null,
            "month": 1,
            "year": 2020,
            "firstName": "Visa",
            "lastName": "card 0026",
            "street": "330 Hudson st",
            "city": "New York",
            "state": "NY",
            "zip": "10013",
            "label": "Visa 0026",
            "preferred": false
        }
        """
        
        do {
            return try JSONDecoder.shared.decode(PaymentMethodResponse.self, from: json.data(using: .utf8)!)
        } catch {
            return nil
        }
    }

    private func getPaymentAccount() -> PaymentMethodResponse! {
        let json = """
        {
            "type": "BANKACCOUNT",
            "id": 137,
            "last4Digits": "5654",
            "routingNumber": "301000000 ",
            "month": null,
            "year": null,
            "firstName": null,
            "lastName": null,
            "street": null,
            "city": null,
            "state": null,
            "zip": null,
            "label": "AMEX Bank Account",
            "preferred": false
        }
        """
        
        do {
            return try JSONDecoder.shared.decode(PaymentMethodResponse.self, from: json.data(using: .utf8)!)
        } catch {
            return nil
        }
    }

    private func getDueDetails() -> PaymentsGetDueDetailsResponse! {
        let json = """
        {
            "errorMessage": null,
            "alertMessage": null,
            "autoDebitAvailable": false,
            "autoDebitEnabled": false,
            "autoDebitEnrolledType": null,
            "autoDebitEnrolledLast4": null,
            "canAcceptPayment": true,
            "hasScheduledPayment": false,
            "scheduledPaymentDate": null,
            "hasPendingPayments": false,
            "pendingPaymentsTotal": null,
            "generalNotifications": [
                {
                    "notificationText": "This policy has an expiration date of <strong>12/25/2017</strong>."
                },
                {
                    "notificationText": "The last payment posted on <strong><strong>09/01/2017</strong></strong> in the amount of <strong><strong>$305.50</strong></strong>.<br /> The last bill was generated on <strong>09/04/2017</strong> in the amount of <strong><strong><strong>$152.02</strong></strong></strong>.<br /> The amount currently due is <strong><strong><strong>$152.02</strong></strong></strong> and is due before <strong><strong>09/17/2017</strong></strong>.<br />"
                }
            ],
            "paymentNotifications": [],
            "displayRenewalDownPaymentOption": false,
            "renewalDownPaymentAmount": null,
            "renewalDownPaymentAmountLabel": null,
            "displayFullPayoffAmountOption": false,
            "fullPayoffAmount": "584.52",
            "fullPayoffAmountLabel": null,
            "displayRenewalDownPaymentPlusCurrentDueOption": false,
            "renewalDownPaymentPlusCurrentDueAmount": null,
            "renewalDownPaymentPlusCurrentDueAmountLabel": null,
            "displayPaidInFullRenewalOption": false,
            "paidInFullRenewalAmount": null,
            "paidInFullRenewalAmountLabel": null,
            "displayNonRenewableFullPayoffAmountOption": true,
            "nonRenewableFullPayoffAmount": "584.52",
            "nonRenewableFullPayoffAmountLabel": "Account Balance",
            "displayCurrentAmountDueOption": true,
            "currentAmountDue": "152.02",
            "currentAmountDueLabel": "Amount Due",
            "displayOtherAmountOption": true,
            "otherAmount": null,
            "otherAmountLabel": "Other Amount",
            "billingFirstName": "GILBERT",
            "billingLastName": "RIVERA",
            "billingStreet": "11351 OSWALT RD",
            "billingCity": "CLERMONT",
            "billingState": "FL",
            "billingZip": "34711-6442",
            "billingEmail": "gilbert_0927@yahoo.com",
            "minimumPayment": "1.00",
            "maximumPayment": "152.02",
            "currentDueDate": "2017-09-17T05:00:00Z",
            "canReinstate": false,
            "status": "A",
            "lapseReason": null,
            "policyExpirationDate": "2017-12-25T06:00:00Z"
        }
        """
        do {
            return try JSONDecoder.shared.decode(PaymentsGetDueDetailsResponse.self, from: json.data(using: .utf8)!)
        } catch {
            return nil
        }
    }
    
}
