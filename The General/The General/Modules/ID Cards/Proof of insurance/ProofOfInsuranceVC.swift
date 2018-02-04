//
//  ProofOfInsuranceVC.swift
//  The General
//
//  Created by Hopkinson, Todd (US - Denver) on 1/11/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit
import WebKit

class ProofOfInsuranceVC: UIViewController {
    
    @IBOutlet weak var overlayControlsView: UIView!
    @IBOutlet weak var pdfContainerView: UIView!
    @IBOutlet weak var overlayActivityIndicator: UIActivityIndicatorView!
    
    var policyNumber: String?
    var driverCount = 1
    var vehicleCount = 1
    var spanish = false
    var pdfBase64String: String?
    var pdfFilename = "proofofinsurance"
    var webView: WKWebView?
    var shouldShowOverlayControls = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlayControlsView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        webView = WKWebView(frame: pdfContainerView.bounds)
        if let webView = webView {
            pdfContainerView.addSubview(webView)
        }
        
        setupProof()
    }
    
    func setupProof() {
        
        if shouldShowOverlayControls {
            overlayControlsView.isHidden = false
        }
        
        guard let policyNumber = policyNumber else { return }
        LoadingView.show()
        showOverlayActivityIndicatorIfNeeded()
        
        ApplicationContext.shared.policyManager.getProofOfInsurance(forPolicy: policyNumber, driverCount: driverCount, vehicleCount: vehicleCount, spanish: spanish) { [weak self] (innerClosure) in
            LoadingView.hide()
            self?.hideOverlayActivityIndicator()
            do {
                let responseModel = try innerClosure()
                self?.pdfBase64String = responseModel.pdfBase64
                if let pdfString = self?.pdfBase64String, let filename = self?.pdfFilename {
                    self?.saveBase64StringToPDF(pdfString, toFilename: filename)
                }
                self?.updateUI()
            } catch {
                print("Error retrieving id card(s): \(error)")
                // TODO: Better error handling
            }
        }
    }
    
    func updateUI() {
        if let request = self.urlRequestForPDF(filename: self.pdfFilename) {
            webView?.load(request)
        }
    }
    
    func showOverlayActivityIndicatorIfNeeded() {
        overlayActivityIndicator.startAnimating()
    }
    
    func hideOverlayActivityIndicator() {
        overlayActivityIndicator.stopAnimating()
    }
    
    
    // MARK: - Button Actions
    @IBAction func printButtonAction(_ sender: Any) {
        self.printPDF()
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        self.sharePDF()
    }
    
    
    // MARK: - Navigation
    @IBAction func overlayDismissButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProofOfInsuranceVC {
    
    func urlRequestForPDF(filename: String) -> URLRequest? {
        var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
        documentsURL?.appendPathComponent("\(filename).pdf")
        guard let url = documentsURL else { return nil }
        return URLRequest(url: url)
    }
    
    func saveBase64StringToPDF(_ base64String: String, toFilename: String) {
        guard let convertedData = Data(base64Encoded: base64String) else { return }
        var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
        documentsURL?.appendPathComponent("\(toFilename).pdf")
        guard let docURL = documentsURL else { return }
        
        do {
            try convertedData.write(to: docURL)
        } catch {
            // TODO: handle write error here
        }
    }
    
    func printPDF() {
        guard let urlRequest = self.urlRequestForPDF(filename: self.pdfFilename) else { return }
        guard let url = urlRequest.url else { return }
        let jobname = url.absoluteString
        let info = UIPrintInfo.printInfo()
        info.outputType = UIPrintInfoOutputType.general
        info.jobName = jobname
        info.orientation = UIPrintInfoOrientation.portrait
        let printController = UIPrintInteractionController.shared
        printController.printInfo = info
        printController.printFormatter = webView?.viewPrintFormatter()
        printController.present(animated: true) { (controller, success, error) in
            if success {
                AnalyticsManager.track(event: .idCardsWasPrinted)
            }
        }
    }
    
    func sharePDF() {
        guard let urlRequest = self.urlRequestForPDF(filename: self.pdfFilename), let url = urlRequest.url else { return }
        let items = [url]
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
}
