//
//  UIViewController+Quotes.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import SafariServices

protocol QuoteNavigatable: class {
    func showGetAQuoteByPhoneActionSheet()
    func showGetAQuoteActionSheet(zipCode: String?)
    func getBrandNewQuote(zipCode: String?)
    func getQuoteWithUserPolicyNumber()
    func continueApplication(quote: QuoteResponse)
    func showExistingQuotes()
}

extension QuoteNavigatable where Self: UIViewController, Self: SFSafariViewControllerDelegate {
    func showGetAQuoteByPhoneActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let titleString = "\(NSLocalizedString("quotes.call", comment: "Call ")) \(ApplicationContext.shared.phoneCallManager.getAQuoteNumber.displayNumber)"
        alertController.addAction(UIAlertAction(title: titleString, style: .default, handler: { (action) in
            ApplicationContext.shared.phoneCallManager.callGetAQuoteNumber()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("quotes.scheduleacallback", comment: "Schedule a call back"), style: .default, handler: { (action) in
            let storyboard = UIStoryboard(name: "Support", bundle: nil)
            if let scheduleACallVC = storyboard.instantiateViewController(withIdentifier: "SupportScheduleACallVC") as? SupportScheduleACallVC {
                self.navigationController?.pushViewController(scheduleACallVC, animated: true)
            }
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", comment: "Cancel"), style: .cancel, handler: { (action) in
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func showGetAQuoteActionSheet(zipCode: String?) {
        if let _ = SettingsManager.refillUrl {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("quotes.newquoteusingmyinfo", comment: "New quote using my info"), style: .default, handler: { (action) in
                // Open Web view and pass in policy number, plus ZIP code (if any)
                self.getQuoteWithUserPolicyNumber()
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("quotes.brandnewquote", comment: "Brand new quote"), style: .default, handler: { (action) in
                // Open Web view and DON'T pass in user info, but DO pass in ZIP code (if any)
                self.getBrandNewQuote(zipCode: zipCode)
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", comment: "Cancel"), style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        } else {
            // Go directly to the Quote WebView
            getBrandNewQuote(zipCode: zipCode)
        }
    }
    
    func getBrandNewQuote(zipCode: String?) {
        if let getAQuoteUrlString = ApplicationContext.shared.quotesManager.requestANewQuoteUrlString() {
            var urlString = getAQuoteUrlString
            if let zipCode = zipCode, zipCode.count == 5 {
                urlString = "\(urlString)&zipCode=\(zipCode)"
            }
            guard let url = URL.init(string: urlString) else { return }
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.delegate = self
            // Using this method because it doesn't work otherwise when signed in (https://forums.developer.apple.com/thread/62012)
            UIApplication.shared.keyWindow!.rootViewController!.present(safariViewController, animated: true, completion: nil)
        }
    }
    
    func getQuoteWithUserPolicyNumber() {
        ApplicationContext.shared.quotesManager.getQuoteRefill(forPolicy: SessionManager.policyNumber ?? "") { [weak self] (innerClosure) in
            guard let weakSelf = self else { return }
            do {
                let quotesRefillUrl = try innerClosure()
                if let url = quotesRefillUrl.url {
                    let urlString = "\(ServiceManager.shared.webContentBaseURL)\(url)"
                    guard let url = URL.init(string: urlString) else { return }
                    let safariViewController = SFSafariViewController(url: url)
                    safariViewController.delegate = self
                    // Using this method because it doesn't work otherwise when signed in (https://forums.developer.apple.com/thread/62012)
                    UIApplication.shared.keyWindow!.rootViewController!.present(safariViewController, animated: true, completion: nil)
                }
            } catch {
                if let serviceError = error as? ServiceErrorType {
                    switch serviceError {
                    case .unsuccessful(let message, let errors):
                        let alert = UIAlertController(title: message, message: errors?[0], preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            weakSelf.dismiss(animated: true, completion: nil)
                        }))
                        weakSelf.present(alert, animated: true, completion: nil)
                        break
                    default:
                        // TODO: Do we need to handle this?
                        break
                    }
                } else {
                    let alert = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        weakSelf.dismiss(animated: true, completion: nil)
                    }))
                    weakSelf.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func continueApplication(quote: QuoteResponse) {
        guard let retrieveAnExistingQuoteUrlString = ApplicationContext.shared.quotesManager.retrieveAnExistingQuoteUrlString(),
            let quoteNumber = quote.quoteNumber,
            let tgt = SessionManager.accessToken
            else { return }
        
        let urlStringWithParameters = "\(retrieveAnExistingQuoteUrlString)&tgt=\(tgt)&quoteNumber=\(quoteNumber)"
        guard let url = URL.init(string: urlStringWithParameters) else { return }
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        // Using this method because it doesn't work otherwise when signed in (https://forums.developer.apple.com/thread/62012)
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
        rootViewController.present(safariViewController, animated: true, completion: nil)
    }
    
    func showExistingQuotes() {
        if let previousQuotesUrlString = ApplicationContext.shared.quotesManager.retrieveAnExistingQuoteUrlString() {
            guard let url = URL.init(string: previousQuotesUrlString) else { return }
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.delegate = self
            // Using this method because it doesn't work otherwise when signed in (https://forums.developer.apple.com/thread/62012)
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
            rootViewController.present(safariViewController, animated: true, completion: nil)
        }
    }
}
