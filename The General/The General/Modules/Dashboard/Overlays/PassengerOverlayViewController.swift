//
//  PassengerOverlayViewController.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/18/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PassengerOverlayViewController: OverlayViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		dims = Dims(maskWidth: 120.0, maskHeight: 120.0, maskHorizontalInset: 80.0, maskVerticalInset: -45.0)
    }


}
