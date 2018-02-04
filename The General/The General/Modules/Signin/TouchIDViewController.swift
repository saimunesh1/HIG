//
//  TouchIDViewController.swift
//  The General
//
//  Created by Irvine, Lee (US - Seattle) on 11/22/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class TouchIDViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTouchUsePassword() {
        self.dismiss(animated: true)
    }

}
