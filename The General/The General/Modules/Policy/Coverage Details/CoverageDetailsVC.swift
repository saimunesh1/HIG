//
//  CoverageDetailsTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class CoverageDetailsVC: UIViewController, PolicyNavigatable {

    struct SegueMap {
        static let coverage = "coverage"
        static let agent = "agent"
    }
    
    @IBOutlet weak var coverageContainer: UIView!
    @IBOutlet weak var coverageControl: CoverageCustomControl!
    
    weak var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    private func setupData() {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            LoadingView.show(inView: rootViewController.view, type: .fullscreen, animated: false)
        }
        ApplicationContext.shared.policyManager.fetchCoverageResponse { [weak self](innerClosure) in
            guard let sSelf = self else { return }
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                LoadingView.hide(inView: rootViewController.view, animated: true)
                sSelf.controlValueTouched(sSelf.coverageControl)
            }
        }
    }
    
    @IBAction func backTouched(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
	@IBAction fileprivate func didTouchModifyPolicyButton(_ sender: UIBarButtonItem!) {
		pushModifyPolicyOnNavigationController()
	}

	@IBAction func controlValueTouched(_ sender: CoverageCustomControl) {
        
        switch sender.value {
        case .coverage:
            if let cnt = UIStoryboard(name: "Policy", bundle: nil).instantiateViewController(withIdentifier: "CoverageDetailTableVC") as? CoverageDetailTableVC {
                cycleViewController(from: self.currentViewController, to: cnt)
                cnt.updateCells()
            }
            break
        case .drivers:
            if let cnt = UIStoryboard(name: "Policy", bundle: nil).instantiateViewController(withIdentifier: "DriverListTableVC") as? DriverListTableVC {
                cycleViewController(from: self.currentViewController, to: cnt)
                cnt.updateCells()
            }
            
            break
        case .vehicles:
            if let vehicles = ApplicationContext.shared.policyManager.vehicleInfo, vehicles.count > 1 {
                if let cnt = UIStoryboard(name: "Policy", bundle: nil).instantiateViewController(withIdentifier: "VehicleListTableVC") as? VehicleListTableVC {
                    cycleViewController(from: self.currentViewController, to: cnt)
                    cnt.updateCells()
                }
            } else {
                if let cnt = UIStoryboard(name: "Policy", bundle: nil).instantiateViewController(withIdentifier: "VehicleDetailTableVC") as? VehicleDetailTableVC {
                    cycleViewController(from: self.currentViewController, to: cnt)
                    cnt.vehicle = ApplicationContext.shared.policyManager.vehicleInfo?.first
                }
            }
            break
        case .agents:
            if let cnt = UIStoryboard(name: "Policy", bundle: nil).instantiateViewController(withIdentifier: "AgentDetailTableVC") as? AgentDetailTableVC {
                cycleViewController(from: self.currentViewController, to: cnt)
                cnt.updateCells()
            }

        }
    }
    
    private func cycleViewController(from viewController: UIViewController?, to childViewController: UIViewController) {
        
        self.addChildViewController(childViewController)
        self.coverageContainer.addSubview(childViewController.view)
        self.addConstraints(between: self.coverageContainer, and: childViewController.view)
        
        if let vc = viewController {
            vc.willMove(toParentViewController: nil)
            transition(from: vc, to: childViewController, duration: 0.01, options: [], animations: {
                
            }, completion: { [weak self](_) in
                guard let sSelf = self else { return }
                vc.removeFromParentViewController()
                childViewController.didMove(toParentViewController: sSelf)
            })
        }
        self.currentViewController = childViewController
        
    }
    
    private func addConstraints(between container: UIView, and childView: UIView) {
        container.translatesAutoresizingMaskIntoConstraints = false
        childView.translatesAutoresizingMaskIntoConstraints = false
        container.topAnchor.constraint(equalTo: childView.topAnchor).isActive = true
        container.leftAnchor.constraint(equalTo: childView.leftAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: childView.bottomAnchor).isActive = true
        container.rightAnchor.constraint(equalTo: childView.rightAnchor).isActive = true
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? SupportVC {
			if currentViewController is DriverListTableVC {
				vc.contextualHelpString = NSLocalizedString("contextualhelp.excludeddriver", comment: "")
			} else if currentViewController is VehicleDetailTableVC {
				vc.contextualHelpString = NSLocalizedString("contextualhelp.comprehensive", comment: "")
			}
		}
	}
	
}
