//
//  ClaimsDetailVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/14/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsDetailVC: BaseVC {
	
	enum RowIndex: Int {
		case topCell = 0
		case detailStatusCell = 1
		case claimsHeadingCell = 2
		case otherCell = 4
	}
	
	@IBOutlet weak var tableView: UITableView!
	
	public var claim: Claim? { didSet { setUpFromClaim() }}
	
	private var adjusterInfo: ClaimAdjusterResponse?
	private var adjusterInfoRowIndex = 0
	private var accidentInfoRowIndex = 0
	private var myVehicle: Vehicle?
	private var myVehicleInfoRowIndex = -1
	private var otherVehiclesRowIndexes: [Int] = []
	private var otherPeopleRowIndex = 0
	private var otherVehicles = [Vehicle]()
	private var reportAnIssueRowIndex = 0
	private var selectedVehicleIndex = 0
	private var setupCompleted = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.tableFooterView = UIView() // Hides separators between empty rows
		registerNibs()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		baseNavigationController?.showMenuButton()
		setUpFromClaim()
		tableView.reloadData()
	}
	
	private func registerNibs() {
		tableView.register(ClaimsHeadingCell.nib, forCellReuseIdentifier: ClaimsHeadingCell.identifier)
		tableView.register(ClaimsClaimDetailDraftCell.nib, forCellReuseIdentifier: ClaimsClaimDetailDraftCell.identifier)
		tableView.register(ClaimsClaimDetailInfoCell.nib, forCellReuseIdentifier: ClaimsClaimDetailInfoCell.identifier)
		tableView.register(ClaimsClaimDetailStatusCell.nib, forCellReuseIdentifier: ClaimsClaimDetailStatusCell.identifier)
		tableView.register(ClaimsClaimDetailTopCell.nib, forCellReuseIdentifier: ClaimsClaimDetailTopCell.identifier)
	}
	
	private func setUpFromClaim() {
		if let claimStatus = claim?.claimStatus {
			switch claimStatus {
			case .draftSaved:
				navigationItem.title = NSLocalizedString("claims.claimdraft", comment: "Claim Draft")
			case .uploadingClaim, .claimSaved:
				navigationItem.title = NSLocalizedString("claims.claimdetails", comment: "Claim Details")
			case .claimSubmitted, .claimEstablished, .appraisalRequested, .resolved:
				if let claimNumber = claim?.claimNumber {
					navigationItem.title = "\(NSLocalizedString("claims.claim", comment: "Claim")) #\(claimNumber)"
				} else {
					navigationItem.title = NSLocalizedString("claims.claimdetails", comment: "Claim Details")
				}
			}
		}
		if let claimId = claim?.claimNumber, !setupCompleted {
			LoadingView.show()
			ApplicationContext.shared.claimsManager.getAdjusterList(claimId: claimId, completion: { [weak self] (innerClosure) in
				guard let weakSelf = self else { return }
				LoadingView.hide()
				weakSelf.setupCompleted = true
				do {
					let responseModel = try innerClosure()
					weakSelf.adjusterInfo = responseModel
					weakSelf.tableView.reloadData()
				} catch {
					// TODO: Better error handling
					print("Error retrieving adjusters for claim: \(error)")
				}
			})

		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? ClaimsAdjusterInfoVC {
			vc.adjusterInfo = adjusterInfo
		} else if let vc = segue.destination as? ClaimsAccidentDetailsVC {
			vc.claim = claim
		} else if let vc = segue.destination as? ClaimsOtherPeopleVC {
			vc.claim = claim
		} else if let vc = segue.destination as? ClaimsMyVehicleDetailsVC {
			vc.vehicle = sender as! Vehicle
		} else if let vc = segue.destination as? ClaimsOtherVehicleDetailsVC {
			vc.vehicleIndex = selectedVehicleIndex
			vc.vehicle = sender as! Vehicle
		} else if let vc = segue.destination as? ClaimsProcessVC {
			if claim?.totalSteps == 9 {
				vc.numberOfSteps = .nine
			} else {
				vc.numberOfSteps = .six
			}
		}
	}

}

extension ClaimsDetailVC: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if claim?.claimStatus == .draftSaved { return 4 }
		var numberOfRows = 3 // 3 rows that are always returned
		if adjusterInfo != nil {
			adjusterInfoRowIndex = numberOfRows // Adjuster info row
			numberOfRows += 1
		}
		if claim?.lossType != nil {
			accidentInfoRowIndex = numberOfRows
			numberOfRows += 1 // Accident Information row
		}
		if let myVehicle = claim?.vehicleList.filter({ $0.policyVehicle != nil }).first {
			myVehicleInfoRowIndex = numberOfRows
			self.myVehicle = myVehicle
			numberOfRows += 1 // My Vehicle row
		}
		if let vehicleList = claim?.vehicleList, vehicleList.count > 0 {
			otherVehicles = vehicleList.filter( { $0 != myVehicle } )
			for index in numberOfRows..<(numberOfRows + otherVehicles.count) {
				otherVehiclesRowIndexes.append(index)
			}
			numberOfRows += otherVehicles.count // Other vehicle rows
		}
		if let otherPeopleList = claim?.partyInvolvedList, otherPeopleList.count > 0 {
			otherPeopleRowIndex = numberOfRows
			numberOfRows += 1
		}
		reportAnIssueRowIndex = numberOfRows
		numberOfRows += 1 // Report an Issue row
		return numberOfRows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.row {
		case RowIndex.topCell.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsClaimDetailTopCell.identifier, for: indexPath) as! ClaimsClaimDetailTopCell
			cell.claim = claim
			return cell
		case RowIndex.detailStatusCell.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsClaimDetailStatusCell.identifier, for: indexPath) as! ClaimsClaimDetailStatusCell
			cell.claim = claim
			cell.delegate = self
			return cell
		case RowIndex.claimsHeadingCell.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsHeadingCell.identifier, for: indexPath) as! ClaimsHeadingCell
			cell.headingLabel.text = NSLocalizedString("claims.claimdetails", comment: "Claim Details")
			return cell
		default:
			
			// If this is a draft claim, show a cell with simulated disabled rows.
			if indexPath.row == RowIndex.otherCell.rawValue && claim?.claimStatus == .draftSaved {
				let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsClaimDetailDraftCell.identifier, for: indexPath) as! ClaimsClaimDetailDraftCell
				cell.delegate = self
				return cell
				
			} else {
				switch indexPath.row {
				case adjusterInfoRowIndex:
					let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsClaimDetailInfoCell.identifier, for: indexPath) as! ClaimsClaimDetailInfoCell
					cell.infoCellLabel.text = NSLocalizedString("claims.adjusterinformation", comment: "Adjuster information")
					return cell
				case accidentInfoRowIndex:
					let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsClaimDetailInfoCell.identifier, for: indexPath) as! ClaimsClaimDetailInfoCell
					cell.infoCellLabel.text = NSLocalizedString("claims.accidentinformation", comment: "Accident information")
					return cell
				case myVehicleInfoRowIndex:
					let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsClaimDetailInfoCell.identifier, for: indexPath) as! ClaimsClaimDetailInfoCell
					cell.infoCellLabel.text = NSLocalizedString("claimreview.myvehicle", comment: "My vehicle")
					return cell
				case otherPeopleRowIndex:
					let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsClaimDetailInfoCell.identifier, for: indexPath) as! ClaimsClaimDetailInfoCell
					cell.infoCellLabel.text = NSLocalizedString("claims.otherpeopleinvolved", comment: "Other people involved")
					return cell
				case reportAnIssueRowIndex:
					let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsClaimDetailInfoCell.identifier, for: indexPath) as! ClaimsClaimDetailInfoCell
					cell.infoCellLabel.text = NSLocalizedString("claims.reportanissue", comment: "Report an issue")
					cell.isInteractive = true
					return cell
				default:
					if let index = otherVehiclesRowIndexes.index(of: indexPath.row) { // Other vehicles
						let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsClaimDetailInfoCell.identifier, for: indexPath) as! ClaimsClaimDetailInfoCell
						cell.infoCellLabel.text = "\(NSLocalizedString("claimreview.vehicle", comment: "Vehicle")) \(index + 2)" // 1 is My Vehicle
						return cell
					}
				}
			}
		}
		return UITableViewCell() // This should never be executed
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case RowIndex.topCell.rawValue: // Top cell; do nothing
			break
		case RowIndex.detailStatusCell.rawValue: // Status cell; do nothing
			break
		case RowIndex.claimsHeadingCell.rawValue: // Details header cell; do nothing
			break
		default:
			if indexPath.row == 3 && claim?.claimStatus == .draftSaved { // Draft cell; do nothing
				break
			} else {
				switch indexPath.row {
				case adjusterInfoRowIndex:
					if let _ = adjusterInfo {
						performSegue(withIdentifier: "showClaimsAdjusterInfoVC", sender: nil)
					}
				case accidentInfoRowIndex:
					performSegue(withIdentifier: "showClaimsAccidentDetailsVC", sender: nil)
				case myVehicleInfoRowIndex:
					performSegue(withIdentifier: "showClaimsMyVehicleDetailsVC", sender: myVehicle)
				case otherPeopleRowIndex:
					performSegue(withIdentifier: "showClaimsOtherPeopleVC", sender: nil)
				case reportAnIssueRowIndex:
					performSegue(withIdentifier: "showSupportVC", sender: nil)
				default: // Other vehicle
					if let index = otherVehiclesRowIndexes.index(of: indexPath.row) {
						selectedVehicleIndex = index
						let vehicle = otherVehicles[selectedVehicleIndex]
						performSegue(withIdentifier: "showClaimsOtherVehicleDetailsVC", sender: vehicle)
					}
				}
			}
		}
	}
	
}

extension ClaimsDetailVC: ClaimsClaimDetailDraftCellDelegate {
	
	func didTapDeleteDraft() {
		print("Delete")
		// TODO: Implemment this
	}
	
}

extension ClaimsDetailVC: ClaimsClaimDetailStatusCellDelegate, ClaimNavigatable {
	
	func didTapActionLink(cell: ClaimsClaimDetailStatusCell) {
		switch cell.claim!.claimStatus! {
		case .claimSubmitted:
			performSegue(withIdentifier: "showClaimsEmailEnrollmentVC", sender: nil)
		case .draftSaved:
			ApplicationContext.shared.navigator.present("pgac://fnol/resume/\(claim!.fnolLocalId!)", context: nil, wrap: nil, from: self, animated: true, completion: nil)
		case .claimSaved:
			askToSubmitClaim(claim: cell.claim!.fnolClaim!)
		default:
			break
		}
		// TODO: Implement this for other action types
	}
	
	func didTapInfoButton() {
		performSegue(withIdentifier: "showClaimsProcessVC", sender: nil)
	}
	
}
