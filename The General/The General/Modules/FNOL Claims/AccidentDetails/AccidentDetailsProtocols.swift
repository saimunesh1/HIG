//
//  AccidentDetailsProtocols.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/16/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol AddressLocationDelegate {
    func onTouchOnSave(addressInfo: FNOLAddressTemporary)
    func didTouchOnLocation()
    func didTouchOnHome()
}

protocol ThreeLocationCellDelegate {
	func didTouchOnAccidentLocation()
	func didTouchOnMyLocation()
	func didTouchOnHome()
}

protocol PickerDelegate {
	func didPickSubField(value: String, displayValue: String, responseKey: String)
    func didAccidentPhotosPicked(imageArray: [FNOLImage])
}

protocol FooterDelegate {
    func didTouchLeftButton()
    func didTouchRightButton()
}
