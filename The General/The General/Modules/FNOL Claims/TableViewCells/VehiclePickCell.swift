//
//  VehiclePickCellTableViewCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class VehiclePickCell: BaseTableViewCell {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueField: UILabel!
	@IBOutlet weak var valueSubField: UILabel!
	
    var field: Field? {
        didSet {
            guard let field = field else { return }
            titleLabel?.text = field.label
			valueField.textColor = .tgTextFontColor
			valueSubField.textColor = .tgTextFontColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var imageView: UIImageView
        imageView  = UIImageView(frame:CGRect(x:10, y:5, width:10, height:10))
        imageView.image = #imageLiteral(resourceName: "arrow")
        accessoryView = imageView
        valueField.textColor = .tgTextFontColor
    }
    
    func fetchMyVehicle(handler: @escaping (FNOLVehicle) -> Void) {
        let tempVehicle = FNOLVehicle.mr_createEntity()!
		ApplicationContext.shared.fnolClaimsManager.activeClaim?.addVehicle(tempVehicle)
        tempVehicle.claim = ApplicationContext.shared.fnolClaimsManager.activeClaim
        tempVehicle.vin = self.getClaimValue(forResponseKey:"myVehicle.vehicleInfo.vin")
        tempVehicle.licensePlate = self.getClaimValue(forResponseKey:"myVehicle.vehicleInfo.licensePlate")
        tempVehicle.year = self.getClaimValue(forResponseKey:"myVehicle.vehicleInfo.year")
        tempVehicle.make = self.getClaimValue(forResponseKey:"myVehicle.vehicleInfo.make")
        tempVehicle.model = self.getClaimValue(forResponseKey:"myVehicle.vehicleInfo.model")
        handler(tempVehicle)
    }
    
    public func getClaimValue(forResponseKey responseKey: String) -> String? {
        guard let value = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: responseKey) else {
            return ""
        }
        return value
    }
	
}
