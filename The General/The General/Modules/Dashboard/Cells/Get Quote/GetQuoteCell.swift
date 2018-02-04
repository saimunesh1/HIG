//
//  GetQuoteCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class GetQuoteCell: UITableViewCell {

    var onDidTouchGetAQuote: (() -> ())?
    var onDidTouchPhoneByQuote: (() -> ())?

    var bordered: Bool = true {
        didSet {
            dashboardBoxView.isHidden = !bordered
        }
    }
    
    @IBOutlet var dashboardBoxView: DashboardBoxView!
    @IBOutlet var quoteByPhoneLabel: UILabel!

    override func awakeFromNib() {
        if let phoneText = quoteByPhoneLabel.text {
            let attributedText = NSMutableAttributedString(string: phoneText)
            let phoneRange = (phoneText as NSString).range(of: "phone")
            
            attributedText.addAttribute(.foregroundColor, value: UIColor.tgGreen, range: phoneRange)
            
            if let boldFont = UIFont(name: "OpenSans-Semibold", size: quoteByPhoneLabel.font.pointSize) {
                attributedText.addAttribute(.font, value: boldFont, range: phoneRange)
            }
            
            quoteByPhoneLabel.attributedText = attributedText
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTouchPhoneLink(_: )))
        quoteByPhoneLabel.addGestureRecognizer(gesture)
    }
    
    @IBAction func didTouchQuoteButton(_ sender: UIButton) {
        onDidTouchGetAQuote?()
    }
    
    @IBAction func didTouchPhoneLink(_ sender: UIButton) {
        onDidTouchPhoneByQuote?()
    }
}
