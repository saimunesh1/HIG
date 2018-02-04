//
//  BaseNavigationViewController.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/28/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UIViewController {

    @IBAction func goBack(segue: UIStoryboardSegue) {
        self.navigationController?.popViewController(animated: true)
    }
    
   

}
