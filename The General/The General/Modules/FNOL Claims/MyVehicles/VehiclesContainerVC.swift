//
//  VehiclesContainerVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/29/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class VehiclesContainerVC: FNOLBaseVC {

    var viewModel: Questionnaire?
    @IBOutlet weak var topBarView: ClaimProcessTracker!
    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let vehiclesVC = childViewControllers.first as? MyVehicleVC else  {
            fatalError("Check storyboard for missing FNOLVehiclesVC")
        }
        
        vehiclesVC.viewModel = viewModel
        vehiclesVC.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
            topBarView.setCurrentPage(self.pageType)
        }
    }
    
    static func instantiate() -> VehiclesContainerVC {
        let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! VehiclesContainerVC
        return vc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - FNOLTopBarNavigatable
extension VehiclesContainerVC: FNOLTopBarNavigatable {
    var pageType: FNOLTopBarPageType {
        // My vehicle is always #1
        return .vehicle(number: 1)
    }
}
