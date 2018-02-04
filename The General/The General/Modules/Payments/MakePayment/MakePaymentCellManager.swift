//
//  MakePaymentActiveCells.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

enum MakePaymentCellIdentifiers: String {
    case paymentAmounts = "PaymentAmounts"
    case paymentAmount = "PaymentAmount"
    case paymentAmountOther = "PaymentAmountOther"
    case splitPaymentYesNo = "SplitPaymentYesNo"
    case singlePayWith = "SinglePayWith"
    case splitPayWith = "SplitPayWith"
    case addAnotherPayment = "AddAnotherPayment"
    case paymentDate = "PaymentDate"
    case submitPayment = "SubmitPayment"
    case schedulePayment = "SchedulePayment"
}

enum PaymentMode {
    case single
    case split
    case scheduled
}

class MakePaymentCellManager: NSObject {
    var activeCells: [MakePaymentCellIdentifiers] = []
    var paymentMode: PaymentMode!

    func enableSplitPay(numberOfPayments: Int) {
        self.paymentMode = .split
        self.activeCells = [
            .paymentAmounts,
            .paymentAmount,
            .splitPaymentYesNo,
            .addAnotherPayment,
            .submitPayment
        ]
        
        for _ in 0..<numberOfPayments {
            self.addSplitPaymentCell()
        }
    }
    
    func enableSchedulePay() {
        self.paymentMode = .scheduled
        self.activeCells = [
            .paymentAmounts,
            .paymentAmount,
            .singlePayWith,
            .paymentDate,
            .schedulePayment
        ]
    }
    
    func enableSinglePay() {
        self.paymentMode = .single
        self.activeCells = [
            .paymentAmounts,
            .paymentAmount,
            .splitPaymentYesNo,
            .singlePayWith,
            .paymentDate,
            .submitPayment
        ]
    }
    
    
    ///  Insert a new split payment cell after the current last split payment cell
    ///
    /// - Returns
    ///   Index of newly inserted split payment cell
    @discardableResult
    func addSplitPaymentCell() -> Int {
        var newSplitPaymentCellIndex = 0
        
        if let lastIndex = self.lastSplitPaymentCell() {
            newSplitPaymentCellIndex = lastIndex
        } else {
            //
            newSplitPaymentCellIndex = self.activeCells.index(where: { $0 == .splitPaymentYesNo }) ?? 0
        }
        
        newSplitPaymentCellIndex += 1
        
        self.activeCells.insert(.splitPayWith, at: newSplitPaymentCellIndex)
        
        return newSplitPaymentCellIndex
    }
    
    func numberOfSplitPaymentCells() -> Int {
        return self.activeCells.filter({ $0 == .splitPayWith }).count
    }
    
    func firstSplitPaymentCell() -> Int? {
        if let index = self.activeCells.index(where: { $0 == .splitPayWith }) {
            return index
        }
        
        return nil
    }
    
    var paymentCellIndexes: [Int] {
        get {
            
            for (index, identifier) in self.activeCells.enumerated() where identifier == .singlePayWith || identifier == .splitPayWith {
                
                if identifier == .singlePayWith {
                    return [index]
                    
                } else {
                    return splitPaymentCellIndexes
                }
            }
            
            return []
        }
    }
    
    var splitPaymentCellIndexes: [Int] {
        get {
            guard let firstIndex = firstSplitPaymentCell() else {
                return []
            }
            
            var indexes: [Int] = []
            
            for index in 0..<numberOfSplitPaymentCells() {
                indexes.append(firstIndex + index)
            }
            
            return indexes
        }
    }
    
    func lastSplitPaymentCell() -> Int? {
        if let indexFromTop = self.activeCells.reversed().index(where: { $0 == .splitPayWith }) {
            return indexFromTop.base - 1
        }
        
        return nil
    }
}
