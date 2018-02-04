//
//  TextViewTableViewCell.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 12/19/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol AttributedLinks: class {
    func openTerms()
    func openPrivacy()
}

class TextViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descTextView: UITextView! {
        didSet {
            descTextView.textContainerInset = .zero
            descTextView.textContainer.lineFragmentPadding = 0
        }
    }
    @IBOutlet weak var descTextHeight: NSLayoutConstraint!
    var config: VCMode = .allowsTexts {
        didSet {
            self.descTextView.attributedText = message
        }
    }
    weak var delegate: AttributedLinks?
    
    var message: NSAttributedString {
        if config == .allowsCalls {
            let text = NSLocalizedString("preferences.allowscalls.terms", comment: "")
            let attributedString = NSMutableAttributedString(string: text, attributes: [
                .font: UIFont.text,
                .foregroundColor: UIColor.tgTextFontColor,
                .kern: -0.5
                ])
            attributedString.addAttributes([
                .font: UIFont.alert,
                .foregroundColor: UIColor.tgGreen,
                .link: URL(string: "general://terms") ?? ""
                ], range: NSRange(location: 125, length: 18))
            attributedString.addAttributes([
                .font: UIFont.alert,
                .foregroundColor: UIColor.tgGreen,
                .link: URL(string: "general://privacypolicy") ?? ""
                ], range: NSRange(location: 148, length: 14))
            descTextView.attributedText = attributedString
            descTextView.linkTextAttributes = [ NSAttributedStringKey.foregroundColor.rawValue: UIColor.tgGreen ]

            return attributedString
        } else {
            let text = NSLocalizedString("preferences.allowstexts.terms", comment: "")
            let attributedString = NSMutableAttributedString(string: text, attributes: [
                .font: UIFont.text,
                .foregroundColor: UIColor.tgTextFontColor,
                .kern: -0.5
                ])
            attributedString.addAttributes([
                .font: UIFont.alert,
                .foregroundColor: UIColor.tgGreen,
                .link: URL(string: "general://terms") ?? ""
                ], range: NSRange(location: 305, length: 18))
            attributedString.addAttributes([
                .font: UIFont.alert,
                .foregroundColor: UIColor.tgGreen,
                .link: URL(string: "general://privacypolicy") ?? ""
                ], range: NSRange(location: 328, length: 14))
            descTextView.attributedText = attributedString
            descTextView.linkTextAttributes = [ NSAttributedStringKey.foregroundColor.rawValue: UIColor.tgGreen ]
            
            return attributedString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descTextView.delegate = self
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        calculateHeight()
    }
    
    func fill(with config: VCMode) {
        self.config = config
    }
    
    private func calculateHeight() {
        let ht: CGFloat = descTextView.sizeThatFits(CGSize(width: descTextView.frame.size.width, height: CGFloat(MAXFLOAT))).height
        descTextHeight?.constant = ht
    }
}

extension TextViewTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if let host = URL.host, let scheme = URL.scheme, scheme == "general" {
            switch host {
            case "terms":
                delegate?.openTerms()
            case "privacypolicy":
                delegate?.openPrivacy()
            default: break
            }
            return false
        }
        return true
    }
}
