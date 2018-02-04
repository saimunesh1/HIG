//
//  MyVehicleEditableRowCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/19/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

protocol MyVehicleEditableRowCellDelegate: class {
	func didUpdate(cell: MyVehicleEditableRowCell)
}

class MyVehicleEditableRowCell: MyVehicleRowCell {
	
	public weak var delegate: MyVehicleEditableRowCellDelegate?

	override func awakeFromNib() {
		super.awakeFromNib()
		valueField.addTarget(self, action: #selector(didChangeText(field: )), for: .editingChanged)
	}
	
	@objc func didChangeText(field: UITextField) {
		delegate?.didUpdate(cell: self)
	}

}
