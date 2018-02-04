//
//  BaseNavigationController.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 11/23/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

extension UIViewController {
    var baseNavigationController: BaseNavigationController? {
        return self.navigationController as? BaseNavigationController
    }
}

class BaseNavigationController: SupplementalNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showMenuButton() {
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "24px__menu"), style: .plain, target: self, action: #selector(didTouchMenuButton))
        menuButton.tintColor = UIColor.tgGreen
        
        self.navigationBar.topItem?.leftBarButtonItem = menuButton
    }
    
    @objc func didTouchMenuButton() {
        if let drawerController = UIApplication.shared.delegate?.window??.rootViewController as? DrawerController {
            drawerController.openDrawer()
        }
    }
}
