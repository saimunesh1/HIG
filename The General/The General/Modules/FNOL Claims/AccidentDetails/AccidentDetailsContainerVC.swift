//
//  AccidentDetailsContainerViewController.swift
//  The General
//
//  Created by Moore, Michael (US - New York) on 10/20/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AccidentDetailsContainerVC: FNOLBaseVC {

    var viewModel: Questionnaire?

    @IBOutlet weak var topBarView: ClaimProcessTracker!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let activeClaim = ApplicationContext.shared.fnolClaimsManager.activeClaim else {
            return
        }

        if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
            
            topBarView.navigationController = self.navigationController
            
            self.supplementalNavigationController?.addSupplementalView(topBarView, atIndex: 0, animated: false)
            
            let forcedTopContraint = accidentDetailsController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
            forcedTopContraint.isActive = true
            
            
            // Setup top bar
            if let vehicleCount = activeClaim.value(forResponseKey: "claim.vehicleCount") {
                let vehicleCount = vehicleCount.lowercased()
                if let vehicleCountNumber = Int(vehicleCount) {
                    topBarView.setupTopBar(carCount: vehicleCountNumber)
                }

				// TODO: Fix this once the API is updated. This originally set the carCount to five,
				// because "5" isn't currently an option in the valid values returned by the API.
				else if vehicleCount == "etc" {
					topBarView.setupTopBar(carCount: 1)
                }
                else {
                    topBarView.setupTopBar(carCount: 1)
                }

                topBarView.setCurrentPage(.accidentDetails)
            }
        }

        accidentDetailsController.viewModel = viewModel
        accidentDetailsController.setupTableView()
    }
    
    var accidentDetailsController: AccidentDetailsVC {
        get {
            guard let accidentDetailsController = childViewControllers.first as? AccidentDetailsVC else  {
                fatalError("Check storyboard for missing AccidentDetailsVC")
            }
            
            return accidentDetailsController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
            topBarView.setCurrentPage(self.pageType)
        }
    }
    
    deinit {
        self.supplementalNavigationController?.removeSupplementalView(atIndex: 0, animated: true)
    }
    
    static func instantiate() -> AccidentDetailsContainerVC {
        let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! AccidentDetailsContainerVC
        
        return vc
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? SupportVC {
			vc.contextualHelpString = NSLocalizedString("contextualhelp.accidentdetails", comment: "")
		}
	}
	
	override func goBack() {
		let alertController = UIAlertController(title: NSLocalizedString("alert.title", comment: "Alert"), message: NSLocalizedString("alert.message.cancel", comment: ""), preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: NSLocalizedString( "alert.cancel", comment: "Cancel"), style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		let goBackAction = UIAlertAction(title: NSLocalizedString("alert.yes", comment: "Yes"), style: .default) { (action) in
			
			// Reset claim
			let atScene = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "claim.atScene")
			let policeAtScene = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "claim.policeAtScene")
			let policeReportNumber = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "claim.policeNumber")
			ApplicationContext.shared.fnolClaimsManager.deleteActiveClaim()
			ApplicationContext.shared.fnolClaimsManager.startNewClaim()
			if let atScene = atScene {
				ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(atScene, displayValue: nil, forResponseKey: "claim.atScene")
			}
			if let policeAtScene = policeAtScene {
				ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(policeAtScene, displayValue: nil, forResponseKey: "claim.policeAtScene")
			}
			if let policeReportNumber = policeReportNumber {
				ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(policeReportNumber, displayValue: nil, forResponseKey: "claim.policeNumber")
			}
			super.goBack()
		}
		alertController.addAction(goBackAction)
		self.present(alertController, animated: true, completion: nil)
		
	}
	
}

extension AccidentDetailsContainerVC: FNOLTopBarNavigatable {
    var pageType: FNOLTopBarPageType {
        return .accidentDetails
    }
}
