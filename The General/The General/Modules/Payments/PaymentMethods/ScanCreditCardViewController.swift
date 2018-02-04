//
//  ScanCreditCardViewController.swift
//  The General
//
//  Created by Leif Harrison on 12/11/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import AVKit

protocol ScanCreditCardViewControllerDelegate: class {
    func scanCreditCardViewController(_ viewController: ScanCreditCardViewController, didScanCard cardInfo: CardIOCreditCardInfo)
}

class ScanCreditCardViewController: UIViewController {

    @IBOutlet weak var cardIOView: CardIOView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var notScanningLabel: UILabel!
    @IBOutlet weak var toggleFlashButton: UIButton!
    @IBOutlet weak var manualEntryButton: UIButton!

    weak public var delegate: ScanCreditCardViewControllerDelegate?

    private var isFlashOn = false

    //--------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //--------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        cardIOView.delegate = self
        cardIOView.guideColor = UIColor.tgGreen
        cardIOView.hideCardIOLogo = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isFlashOn = false
        toggleTorch(on: isFlashOn)
        toggleFlashButton.isSelected = isFlashOn
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @IBAction func toggleFlash(_ sender: UIButton) {
        isFlashOn = !isFlashOn
        toggleTorch(on: isFlashOn)
        toggleFlashButton.isSelected = isFlashOn
    }

    @IBAction func manualEntrySelected(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    func toggleTorch(on: Bool) {

        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = on ? .on : .off
                device.unlockForConfiguration()
            }
            catch {
                print("Torch could not be used")
            }
        }
        else {
            print("Torch is not available")
        }
    }
}

//==============================================================================
// MARK: - UITextFieldDelegate
//==============================================================================

extension ScanCreditCardViewController: CardIOViewDelegate {

    func cardIOView(_ cardIOView: CardIOView!, didScanCard cardInfo: CardIOCreditCardInfo!) {
        delegate?.scanCreditCardViewController(self, didScanCard: cardInfo)
        dismiss(animated: true, completion: nil)
    }

}
