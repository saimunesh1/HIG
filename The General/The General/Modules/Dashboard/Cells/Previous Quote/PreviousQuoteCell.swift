//
//  PreviousQuoteCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PreviousQuoteCell: UITableViewCell {
    private struct Dimension {
        static let nonContinueableApplicationCellHeight: CGFloat = 66.0
        static let continueableApplicationCellHeight: CGFloat = 106.0
    }
    
    var quote: QuoteResponse? {
        didSet {
            updateView()
        }
    }
 
    var onContinueApplication: ((QuoteResponse) -> ())?
    
    @IBOutlet var vehicleLabel: UILabel!
    @IBOutlet var quoteDateLabel: UILabel!
    @IBOutlet var continueApplicationButton: UIButton!

    public static func heightForCell(quote: QuoteResponse) -> CGFloat {
        return quote.allowsContinuingOfApplication ? Dimension.continueableApplicationCellHeight : Dimension.nonContinueableApplicationCellHeight
    }
    
    private func updateView() {
        vehicleLabel.text = nil
        quoteDateLabel.text = nil
        continueApplicationButton.isHidden = true
        
        if let quote = quote {
            vehicleLabel.text = quote.quoteVehicles?.first?.yearMakeAndModel
        
            if let quoteDateString = quote.date, let date = DateFormatter.iso8601.date(from: quoteDateString) {
				quoteDateLabel.text = DateFormatter.fullDateTime.string(from: date)
            }

            if quote.allowsContinuingOfApplication {
                continueApplicationButton.isHidden = false
            }
        }
    }
    
    @IBAction func didTouchContinueButton(_ sender: UIButton) {
        if let quote = quote {
            onContinueApplication?(quote)
        }
    }
}
