//
//  PaymentDateTableViewCell.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 1/19/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PaymentDateTableViewCell: UITableViewCell {
    @IBOutlet weak var paymentDateLabel: UILabel!
    var textField: UITextField!
    private var datePicker: UIDatePicker!
    
    private var dateFormatter: DateFormatter!
    
    func showDateSelector() {
        self.textField.becomeFirstResponder()
    }
    
    var value: Date? {
        didSet {
            if let newDate = self.value {
                self.paymentDateLabel.text = self.dateFormatter.string(from: newDate)
                self.datePicker.date = newDate
                ApplicationContext.shared.paymentsManager.scheduledPaymentDate = newDate
            } else {
                self.paymentDateLabel.text = ""
            }
        }
    }
    
    var dateChangeAllowed = true {
        didSet {
            self.textField.isEnabled = dateChangeAllowed
            
            if dateChangeAllowed {
                self.paymentDateLabel.textColor = UIColor.tgGreen
                self.paymentDateLabel.font = UIFont.link
                
            } else {
                self.paymentDateLabel.textColor = UIColor.gray
                self.paymentDateLabel.font = UIFont.largeText
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.dateFormatter = DateFormatter.monthDayYear

        self.datePicker = UIDatePicker()
        self.datePicker.datePickerMode = .date
        self.datePicker.addTarget(self, action: #selector(datePickerChanged(_: )), for: .valueChanged)
        
        // allow only future dates
        self.datePicker.minimumDate = Date()
        
        // do not allow dates more than 30 days out
        let oneday = Double(3600 * 24)
        self.datePicker.maximumDate = Date(timeIntervalSinceNow: oneday * 30)
        
        self.textField = UITextField(frame: CGRect.zero)
        self.textField.autoresizingMask = [ .flexibleHeight, .flexibleWidth ]
        self.textField.inputView = datePicker;
        // hide blinky cursor
        self.textField.tintColor = UIColor.clear
        
        self.contentView.addSubview(self.textField)
        
        self.selectionStyle = .none
    }
    
    @objc internal func datePickerChanged(_ sender: Any) {
        self.value = self.datePicker.date
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.textField.becomeFirstResponder()
        }
    }

}
