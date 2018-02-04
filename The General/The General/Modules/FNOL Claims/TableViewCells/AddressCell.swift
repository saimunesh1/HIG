//
//  AddressTypeCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AddressCell: BaseTableViewCell {
    
    @IBOutlet var addressValueLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    var accidentLocationAddress: FNOLAddressTemporary?{
        didSet{
            self.addressValueLabel.textColor = ThemeColors.TextColors.titleColor
        }
    }
    
    var field: Field? {
        didSet {
            guard let vlaue = field else { return }
            self.addressLabel?.text = vlaue.label
        }
    }
    
    func checkRequired() {
        if (self.field?.required)! {
            self.addressLabel.attributedText = Helper.requiredAttributedText(text:(self.field?.label!)!)}else{
            self.addressLabel.text = self.field?.label}
    }
    
    func getSavedAddressString() {
        
		let address = ApplicationContext.shared.fnolClaimsManager.activeClaim?.addressAsString(addressType: .accidentLocation)
        if address?.isEmpty ?? true {
            self.addressValueLabel.textColor = .extraLightGray
             self.addressValueLabel.text = "Input Address"
            return
        }
        self.addressValueLabel.textColor = ThemeColors.TextColors.titleColor
        self.addressValueLabel.text = address
    }
    
    func getSavedConditionLocationString() {
        
        let address = ApplicationContext.shared.fnolClaimsManager.activeClaim?.addressAsString(addressType: .vehiclelocation)
        if address?.isEmpty ?? true {
            self.addressValueLabel.textColor = .extraLightGray
            self.addressValueLabel.text = "Input Address"
            return
        }
        self.addressValueLabel.textColor = ThemeColors.TextColors.titleColor
        self.addressValueLabel.text = address
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let trimmedString = self.addressValueLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        addressValueLabel.textColor = self.accidentLocationAddress == nil || (trimmedString!.isEmpty) ? .extraLightGray : .tgTextFontColor
        var imageView: UIImageView
        imageView  = UIImageView(frame:CGRect(x:10, y:5, width:10, height:10))
        imageView.image = #imageLiteral(resourceName: "arrow")
        accessoryView = imageView
    }
    
}
