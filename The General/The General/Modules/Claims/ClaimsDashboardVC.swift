//
//  ClaimsDashboardVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/12/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsDashboardVC: BaseVC, OverlayNavigatable {
	
	enum ClaimTypeIndex: Int {
		case outstandingClaims = 0
		case resolvedClaims = 1
	}
	
	struct ClaimDashboardRow {
		var claimCellModel: ClaimCellModel?
		var headerText: String?
	}

	@IBOutlet weak var addClaimButton: UIButton!
	@IBOutlet weak var blankView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var helpButton: UIButton!
	@IBOutlet weak var startClaimButton: BorderUIButton!

	private var hasClaimsInfo = false
	private var claimEntries = [ClaimEntry]()
	private var outstandingClaimCellModels = [ClaimCellModel]()
	private var resolvedClaimCellModels = [ClaimCellModel]()
	private var rows = [ClaimDashboardRow]()

	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
		if !hasClaimsInfo {
			tableView.alpha = 0.0
		}
        addClaimButton.tintColor = .tgGreen
        helpButton.tintColor = .tgGreen
		startClaimButton.backgroundColor = .tgGreen
		registerNibs()
		baseNavigationController?.showMenuButton()
		view.bringSubview(toFront: blankView)
        
        // tutorial overlay
        showHelpCenterOverlayIfNecessary()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		refreshClaimsList() // Moved to viewWillAppear so a new FNOL claim will show up in the list
	}

	private func registerNibs() {
		tableView.register(ClaimsClaimCell.nib, forCellReuseIdentifier: ClaimsClaimCell.identifier)
		tableView.register(ClaimsHeadingCell.nib, forCellReuseIdentifier: ClaimsHeadingCell.identifier)
	}
	
	private func refreshClaimsList() {
		rows = [ClaimDashboardRow]()
		outstandingClaimCellModels = [ClaimCellModel]()
		resolvedClaimCellModels = [ClaimCellModel]()
		
		// If a claim returned by the service has a referenceNumber other than 0, that means it was submitted from
		// the app, which means there's a chance that the corresponding FNOLClaim is still on this device.
		// If that's the case, we want to assign the FNOLClaim to the ClaimCellModel for that claim (so we can
		// show photos), but we want to use the status info returned by the getClaimList call.
		// We need to be careful to show such a claim only once, even if it's both on the device and returned by the service.
		
		// Get local FNOLClaims
		if let fnolClaims = FNOLClaim.mr_findAll() as? [FNOLClaim], fnolClaims.count > 0 {
			for fnolClaim in fnolClaims {
				let claimCellModel = ClaimCellModel()
				claimCellModel.populateFrom(fnolClaim: fnolClaim)
				outstandingClaimCellModels.append(claimCellModel)
			}
		}

		// Get claims from getClaimsList service
		guard let policyNumber = SessionManager.policyNumber else { return }
		LoadingView.show()
		ApplicationContext.shared.claimsManager.getClaims(forPolicy: policyNumber) { [weak self] (innerClosure) in
			guard let weakSelf = self else { return }
			LoadingView.hide()
			do {
				let responseModel = try innerClosure()
				if let claims = responseModel.claims, claims.count > 0 {
					weakSelf.claimEntries = claims
					weakSelf.showClaims()
				} else {
					if weakSelf.outstandingClaimCellModels.count > 0 {
						weakSelf.showClaims()
					} else {
						weakSelf.view.sendSubview(toBack: weakSelf.blankView)
					}
				}
			} catch {
				weakSelf.view.sendSubview(toBack: weakSelf.blankView)
				print("Error retrieving list of claims: \(error)")
				// TODO: Better error handling

				if weakSelf.outstandingClaimCellModels.count > 0 {
					weakSelf.showClaims()
				} else {
					weakSelf.view.sendSubview(toBack: weakSelf.blankView)
				}
			}
		}
	}
	
	private func showClaims() {
		combineClaims()
		tableView.reloadData()
		showTableView()
	}
	
	// Gather claims data from all sources and convert it into a list of ClaimCellModel objects to be displayed in the list
	private func combineClaims() {
		for claimEntry in claimEntries {

			// If the claim returned by the server has a referenceNumber that matches the referenceNumber of an FNOLClaim on this device,
			// copy the status info from the server into the FNOLClaim's claimCellModel
			if claimEntry.referenceNumber != 0, let matchingFnolClaim = outstandingClaimCellModels.first(where: { $0.referenceNumber == claimEntry.referenceNumber }) {
				// This should be a reference because ClaimCellModel is a class
				matchingFnolClaim.populateFrom(claimEntry: claimEntry)
			} else { // No matching reference number, so create a ClaimCellModel from scratch
				let claimCellModel = ClaimCellModel()
				claimCellModel.populateFrom(claimEntry: claimEntry)
				if claimEntry.status != ClaimStatus.resolved.rawValue {
					outstandingClaimCellModels.append(claimCellModel)
				} else {
					resolvedClaimCellModels.append(claimCellModel)
				}
			}
		}
		// Combine the claims into rows & headers
		if outstandingClaimCellModels.count > 0 {
			rows.append(ClaimDashboardRow(claimCellModel: nil, headerText: NSLocalizedString("claims.outstanding", comment: "Outstanding")))
			for claimCellModel in outstandingClaimCellModels {
				rows.append(ClaimDashboardRow(claimCellModel: claimCellModel, headerText: nil))
			}
		}
		if resolvedClaimCellModels.count > 0 {
			rows.append(ClaimDashboardRow(claimCellModel: nil, headerText: NSLocalizedString("claims.resolved", comment: "Resolved")))
			for claimCellModel in resolvedClaimCellModels {
				rows.append(ClaimDashboardRow(claimCellModel: claimCellModel, headerText: nil))
			}
		}
	}
	
	private func showTableView() {
		view.bringSubview(toFront: tableView)
		tableView.reloadData()
		UIView.animate(withDuration: 0.25) { [weak self] in
			guard let weakSelf = self else { return }
			weakSelf.tableView.alpha = 1.0
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? ClaimsDetailVC, let claim = sender as? Claim {
			vc.claim = claim
		}
	}
	
	private func startNewClaim() {
		ApplicationContext.shared.navigator.present("pgac://fnol/start", context: nil, wrap: nil, from: self, animated: true, completion: nil)
	}
	
	@IBAction func didPressStartNewClaim(_ sender: Any) {
		startNewClaim()
	}
	
	@IBAction func didPressStartClaimsProcess(_ sender: Any) {
		startNewClaim()
	}
}

extension ClaimsDashboardVC: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rows.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = rows[indexPath.row]
		if let headerText = row.headerText {
			let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsHeadingCell.identifier, for: indexPath) as! ClaimsHeadingCell
			cell.headingLabel.text = headerText
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsClaimCell.identifier, for: indexPath) as! ClaimsClaimCell
			cell.claimCellModel = row.claimCellModel
			cell.delegate = self
			return cell
		}
	}
	
    // IMPORTANT: changes here may need to be replicated in OutstandingClaimsCell, too, as part of Dashboard
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = rows[indexPath.row]
		if let claimCellModel = row.claimCellModel {
			
			// Get claim number
			if let claimId = claimCellModel.claimNumber, !claimId.isEmpty {
				
				// Get claim from getClaimInformation service
				LoadingView.show()
				ApplicationContext.shared.claimsManager.getClaim(claimId: claimId, completion: { (innerClosure) in
					LoadingView.hide()
					do {
						let responseModel = try innerClosure()
						var claim = Claim(claimResponse: responseModel)
						claim.claimStatus = claimCellModel.claimStatus
						self.performSegue(withIdentifier: "showClaimsDetailVC", sender: claim)
					} catch {
						// TODO: Better error handling
						print("Error retrieving list of claims: \(error)")
					}
				})
			} else { // No claim number; this claim has not yet been submitted
				if let fnolClaim = claimCellModel.fnolClaim {
					let claim = Claim(fnolClaim: fnolClaim)
					self.performSegue(withIdentifier: "showClaimsDetailVC", sender: claim)
				}
			}
		}
	}
	
}

extension ClaimsDashboardVC: ClaimsClaimCellDelegate, ClaimNavigatable {
	
	func didTapActionLink(cell: ClaimsClaimCell) {
		switch cell.claimCellModel!.claimStatus! {
		case .claimSubmitted:
			performSegue(withIdentifier: "showClaimsEmailEnrollmentVC", sender: nil)
		case .draftSaved:
			ApplicationContext.shared.navigator.present("pgac://fnol/resume/\(cell.claimCellModel!.fnolClaim!.localId!)", context: nil, wrap: nil, from: self, animated: true, completion: nil)
		case .claimSaved:
			askToSubmitClaim(claim: cell.claimCellModel!.fnolClaim!)
		default:
			break
		}
	}
}
