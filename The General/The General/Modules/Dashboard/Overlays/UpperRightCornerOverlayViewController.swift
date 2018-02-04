//
//  UpperRightCornerOverlayViewController.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/22/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class UpperRightCornerOverlayViewController: OverlayViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		dims = Dims(maskWidth: 120.0, maskHeight: 120.0, maskHorizontalInset: 80.0, maskVerticalInset: 25.0)
	}

}
