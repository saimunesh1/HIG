//
//  PaymentsManager.swift
//  The General
//
//  Created by Derek Bowen on 10/9/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

enum SubmitPaymentErrorType: Error {
    case missingDueDetails
    case missingPaymentSession
    case belowMinimumPayment
    case aboveMaximumPayment
    case noPaymentMethods
    case belowSplitPaymentTotal
    case badPaymentDate
}

typealias SubmitPaymentClosure = (_ successes: [MakePaymentEntry], _ failures: [MakePaymentEntry]) -> ()

class PaymentsManager {
    let serviceConsumer = PaymentsServiceConsumer()
    
    typealias GetDueDetailsClosure = (() throws -> PaymentsGetDueDetailsResponse) -> Void
    typealias GetSavedPaymentMethodsClosure = (() throws -> [PaymentMethodResponse]) -> Void
    typealias AddPaymentMethodClosure = (() throws -> Void) -> Void
    typealias UpdatePaymentMethodClosure = (() throws -> Void) -> Void
    typealias DeletePaymentMethodClosure = (() throws -> Void) -> Void
    typealias GenerateTokenClosure = (() throws -> String) -> Void
    
    
    /// Payment due details
    var dueDetails: PaymentsGetDueDetailsResponse?
    
    /// Active make payment session
    var activeMakePaymentSession: MakePaymentSession?
    
    var scheduledPaymentDate: Date?
    
    /// Start a payment session with default payment values
    func startMakePaymentSession() {
        guard let dueDetails = self.dueDetails,
            let policyNumber = SessionManager.policyNumber else {
                self.activeMakePaymentSession = nil
                return
        }
        
        self.activeMakePaymentSession = MakePaymentSession(
            policyNumber: policyNumber,
            amount: dueDetails.currentAmountDue?.rawValue ?? 0,
            availablePaymentAmountMethods: dueDetails.availablePaymentAmountMethods(),
            selectedPaymentAmountMethod: .currentAmountDue,
            paymentDate: dueDetails.currentDueDate ?? Date()
        )
    }
    
    /// Get's details about the user's policy payment information.
    ///
    /// - Parameters:
    ///   - policyNumber: Account holder's policy number
    ///   - completion: Completion handler
    func getDueDetails(forPolicy policyNumber: String, completion: @escaping GetDueDetailsClosure) {
        self.serviceConsumer.getDueDetails(forPolicy: policyNumber) { (innerClosure) in
            completion({ [weak self] () -> PaymentsGetDueDetailsResponse in
                do {
                    let dueDetails = try innerClosure()
                    self?.dueDetails = dueDetails
                    return dueDetails
                }
                catch {
                    throw error
                }
            })
        }
    }
    
    /// Get saved payment methods on the user's account.
    ///
    /// - Parameters:
    ///   - policyNumber: Account holder's policy number
    ///   - completion: Completion handler
    func getSavedPaymentMethods(forPolicy policyNumber: String, completion: @escaping GetSavedPaymentMethodsClosure) {
        self.serviceConsumer.getSavedPaymentMethods(forPolicy: policyNumber) { (innerClosure) in
            completion(innerClosure)
        }
    }
    
    /// Add a credit/debit card to the available payment methods
    ///
    /// - Parameters:
    ///   - cardRequest: Request object containing the credit card details
    ///   - completion: Completion handler
    func addCreditCard(request: AddCardRequest, completion: @escaping AddPaymentMethodClosure) {
        self.serviceConsumer.addCreditCard(request: request) { (innerClosure) in
            completion(innerClosure)
        }
    }
    
    /// Update credit/debit card details
    ///
    /// - Parameters:
    ///   - cardRequest: Request object containing the credit card details
    ///   - completion: Completion handler
    func updateCreditCard(request: UpdateCardRequest, completion: @escaping UpdatePaymentMethodClosure) {
        self.serviceConsumer.updateCreditCard(request: request) { (innerClosure) in
            completion(innerClosure)
        }
    }
    
    /// Delete credit/debit card
    ///
    /// - Parameters:
    ///   - id: The id of the credit/debit card payment method
    ///   - completion: Completion handler
    func deleteCreditCard(request: DeleteCardRequest, completion: @escaping DeletePaymentMethodClosure) {
        self.serviceConsumer.deleteCreditCard(request: request) { (innerClosure) in
            completion(innerClosure)
        }
    }
    
    /// Add a bank account to the available payment methods
    ///
    /// - Parameters:
    ///   - bankAccountRequest: Request object containing the bank account details
    ///   - completion: Completion handler
    func addBankAccount(request: AddBankAccountRequest, completion: @escaping AddPaymentMethodClosure) {
        self.serviceConsumer.addBankAccount(request: request) { (innerClosure) in
            completion(innerClosure)
        }
    }
    
    /// Update bank account details
    ///
    /// - Parameters:
    ///   - bankAccountRequest: Request object containing the bank account details
    ///   - completion: Completion handler
    func updateBankAccount(request: UpdateBankAccountRequest, completion: @escaping UpdatePaymentMethodClosure) {
        self.serviceConsumer.updateBankAccount(request: request) { (innerClosure) in
            completion(innerClosure)
        }
    }
    
    /// Delete bank account
    ///
    /// - Parameters:
    ///   - id: The id of the bank account payment method
    ///   - completion: Completion handler
    func deleteBankAccount(request: DeleteBankAccountRequest, completion: @escaping DeletePaymentMethodClosure) {
        self.serviceConsumer.deleteBankAccount(request: request) { (innerClosure) in
            completion(innerClosure)
        }
    }
    
    /// Generates a single use token for a credit card
    ///
    /// - Parameters:
    ///   - request: Request object containing credit card details
    ///   - completion: Completion handler, returns the generated token
    func generateToken(request: GenerateTokenRequest, completion: @escaping GenerateTokenClosure) {
        self.serviceConsumer.generateToken(request: request) { (innerClosure) in
            completion(innerClosure)
        }
    }
    
    /// Submit a scheduled payment for the user's policy
    /// * uses self.scheduledPaymentDate to determine date
    /// - Parameters:
    ///   - finished: Callback to determine
    func submitScheduledPayment(_ finished: @escaping SubmitPaymentClosure) throws {
        guard let dueDetails = self.dueDetails else {
            throw SubmitPaymentErrorType.missingDueDetails
        }
        guard let paymentSession = self.activeMakePaymentSession else {
            throw SubmitPaymentErrorType.missingPaymentSession
        }
        
        if let maximumPaymentAmount = dueDetails.maximumPayment?.rawValue, paymentSession.amount > maximumPaymentAmount {
            throw SubmitPaymentErrorType.aboveMaximumPayment
        }
        
        guard let paymentEntry = paymentSession.paymentEntries.first,
            let paymentMethod = paymentEntry.paymentMethod else {
                throw SubmitPaymentErrorType.noPaymentMethods
        }
        
        // Verify payment date in range
        let oneday: TimeInterval = 3600 * 24
        
        let dateRange = (Date() ... Date(timeInterval: oneday * 30, since: Date()) )
        
        guard let paymentDate = self.scheduledPaymentDate else {
            throw SubmitPaymentErrorType.badPaymentDate
        }
        
        guard dateRange.contains(paymentDate) else {
            throw SubmitPaymentErrorType.badPaymentDate
        }
        
        // set payment entry amount to full amount from session
        paymentEntry.amount = paymentSession.amount
        
        guard let schedulePaymentRequest = SchedulePaymentRequest(
            policyNumber: paymentSession.policyNumber,
            amount: paymentSession.amount,
            paymentAmountMethod: paymentSession.selectedPaymentAmountMethod,
            paymentMethodResponse: paymentMethod,
            paymentDate: paymentDate) else {
                
                throw SubmitPaymentErrorType.noPaymentMethods
        }
        
        self.serviceConsumer.schedulePayment(request: schedulePaymentRequest, completion: { innerClosure in
            do {
                _ = try innerClosure()
                finished([paymentEntry], [])
            } catch {
                finished([], [paymentEntry])
            }
        })
        
    }
    
    /// Submit an immediate payment for the user's policy.
    /// * Handles any number of immediate payments.
    /// * Split payments are fired simultaneously using a Dispatch Group to wait for all responses
    /// * All responses are sorted into a list of declined and processed payments
    /// * self.scheduledPaymentDate is ignored
    /// * Parameters:
    ///   - finished: Callback containing each declined and processed payment cards.
    ///     *result does not contain innerclosure
    ///
    func submitImmediatePayment(_ finished: @escaping SubmitPaymentClosure) throws {
        guard let dueDetails = self.dueDetails else {
            throw SubmitPaymentErrorType.missingDueDetails
        }
        guard let paymentSession = self.activeMakePaymentSession else {
            throw SubmitPaymentErrorType.missingPaymentSession
        }
        
        // Verify minimum payment amount
        let minimumPaymentAmount = dueDetails.minimumPayment?.rawValue ?? 1
        guard minimumPaymentAmount < paymentSession.amount else {
            throw SubmitPaymentErrorType.belowMinimumPayment
        }
        
        // Verify maximum payment amount
        let maximumPaymentAmount = dueDetails.maximumPayment?.rawValue ?? 99999
        guard maximumPaymentAmount >= paymentSession.amount else {
            throw SubmitPaymentErrorType.aboveMaximumPayment
        }
        
        // check all the payment methods have payment entries
        guard paymentSession.paymentEntries.count > 0 else {
            throw SubmitPaymentErrorType.noPaymentMethods
        }
        
        // check for missing payment methods
        for paymentEntry in paymentSession.paymentEntries {
            if paymentEntry.paymentMethod == nil {
                throw SubmitPaymentErrorType.noPaymentMethods
            }
        }
        
        var failingEntries = [MakePaymentEntry]()
        var successfulEntries = [MakePaymentEntry]()
        
        let dgroup = DispatchGroup()

        if paymentSession.paymentEntries.count > 1 {
            AnalyticsManager.track(event: .paymentsMultipleInitiated)
        }
        
        paymentSession.paymentEntries.forEach { paymentEntry in
            let paymentMethod = paymentEntry.paymentMethod! // <-- guaranteed by paymentEntry check loop
            let card = MakePaymentCardInfo(paymentMethodResponse: paymentMethod)
            let account = MakePaymentBankAccountInfo(paymentMethodResponse: paymentMethod)
            
            if let suggestedAmount = paymentEntry.suggestedAmount, paymentEntry.amount == 0 {
                paymentEntry.amount = suggestedAmount
            }
            
            let makePaymentRequest = MakePaymentRequest(
                policyNumber: paymentSession.policyNumber,
                amount: paymentEntry.amount,
                type: paymentMethod.type,
                selectedPaymentAmountMethod: paymentSession.selectedPaymentAmountMethod,
                operationType: (paymentMethod.saveForLater) ? .saved : .temporary,
                card: card,
                account: account
            )
            
            // wait for each payment to complete before callback
            
            dgroup.enter()
            
            self.serviceConsumer.makePayment(request: makePaymentRequest) { (innerClosure) in
                do {
                    _ = try innerClosure()
                    successfulEntries.append(paymentEntry)
                } catch {
                    failingEntries.append(paymentEntry)
                }
                
                dgroup.leave()
            }
        }
        
        dgroup.notify(queue: DispatchQueue.main) {

            if paymentSession.paymentEntries.count > 1 {
                if successfulEntries.count > 0 {
                    AnalyticsManager.track(event: .paymentsMultipleCompleted)
                }
                if failingEntries.count > 0 {
                    AnalyticsManager.track(event: .paymentsMultipleDeclined)
                }
            }
            
            finished(successfulEntries, failingEntries)
        }
        
    }
    
    
    // MARK: - Pay Near Me
    func activatePayNearMe(withAmount amount: Decimal, success: @escaping (_ url: URL) -> (), failure: ((_ issue: PayNearMeIssue)->())? = nil) throws {
        
        do {
            try self.serviceConsumer.activatePayNearMe(withAmount: amount, success: success, failure: { error in
                
                guard let failure = failure else {
                    return
                }
                
                if error is ServiceErrorType {
                    failure(.serviceNotResponding)
                    
                } else if error is XMLErrorType {
                    failure(.interpretationFailed)
                }
            })
            
        } catch let issue {
            throw issue
        }
    }
}



/// Used to help track state in a make payment session
class MakePaymentSession {
    /// User's policy number
    var policyNumber: String
    
    /// Total amount to pay
    var amount: Decimal
    
    /// Available quick-pick options
    var availablePaymentAmountMethods: [PaymentAmountMethodType]
    
    /// Quick-pick option used to select payment amount
    var selectedPaymentAmountMethod: PaymentAmountMethodType
    
    /// Date of the payment
    var paymentDate: Date
    
    /// Payment requests to make
    var paymentEntries: [MakePaymentEntry] = []
    
    /// Temporary payment methods added during the session
    var temporaryPaymentMethods: [PaymentMethodResponse] = []
    
    init(policyNumber: String, amount: Decimal, availablePaymentAmountMethods: [PaymentAmountMethodType], selectedPaymentAmountMethod: PaymentAmountMethodType, paymentDate: Date) {
        self.policyNumber = policyNumber
        self.amount = amount
        self.availablePaymentAmountMethods = availablePaymentAmountMethods
        self.selectedPaymentAmountMethod = selectedPaymentAmountMethod
        self.paymentDate = paymentDate
    }
}

class MakePaymentEntry {
    var amount: Decimal = 0
    var suggestedAmount: Decimal?
    var paymentMethod: PaymentMethodResponse?
}
