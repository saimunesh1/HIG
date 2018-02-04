//
//  ClaimReviewVC.swift
//  The General
//
//  Created by Trevor Alyn on 11/9/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import MagicalRecord

public enum SummaryRowType {
	case header
	case body
	case details
}

public struct SummaryRow {
	var type: SummaryRowType
	var leftLabelText: String?
	var rightLabelText: String?
	var rightSubLabelText: String?
}

class ClaimReviewVC: FNOLBaseVC {
	
	@IBOutlet weak var tableView: UITableView!
	
	private var summaryRows = [SummaryRow]()
	
	static func instantiate() -> ClaimReviewVC {
		let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! ClaimReviewVC
		return vc
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setUpTableView()
		setUpRows()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadFromCoreData {
			self.tableView.reloadData()
		}
	}

	private func setUpTableView() {
		registerNibs()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableViewAutomaticDimension
		self.title = NSLocalizedString("claimreview", comment: "Claim review")
	}
	
	private func registerNibs() {
		tableView.register(ClaimSummaryHeaderCell.nib, forCellReuseIdentifier: ClaimSummaryHeaderCell.identifier)
		tableView.register(ClaimSummaryBasicCell.nib, forCellReuseIdentifier: ClaimSummaryBasicCell.identifier)
		tableView.register(ClaimSummaryDetailsCell.nib, forCellReuseIdentifier: ClaimSummaryDetailsCell.identifier)
		tableView.register(TableFooterView.nib, forHeaderFooterViewReuseIdentifier: TableFooterView.identifier)
	}
	
	private func loadFromCoreData(completion: (() -> Void)?) {
		completion?()
	}
	
	private func setUpRows() {
		guard let activeClaim = ApplicationContext.shared.fnolClaimsManager.activeClaim else { return }
        summaryRows = [SummaryRow]()
        
        // Header: The accident
        let headerRow1 = SummaryRow(type: .header, leftLabelText: NSLocalizedString("claimreview.theaccident", comment: "The accident"), rightLabelText: nil, rightSubLabelText: nil)
        summaryRows.append(headerRow1)
        
        // Accident type
        let accidentType = ApplicationContext.shared.fnolClaimsManager.activeClaim?.displayValue(forResponseKey: "accidentDetails.whatHappened.type")
        let accidentTypeRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("claimreview.type", comment: "Type"), rightLabelText: accidentType, rightSubLabelText: nil)
        summaryRows.append(accidentTypeRow)
        
        // Where
		if let location = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "accidentDetails.address"), !location.isEmpty {
			let locationRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("claimreview.where", comment: "Where"), rightLabelText: location, rightSubLabelText: nil)
			summaryRows.append(locationRow)
		}
		
        // When
        let accidentDate = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "accidentDetails.dateOfAccident")
        let accidentTime = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "accidentDetails.timeOfAccident")
        let accidentDateTimeRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("claimreview.when", comment: "When"), rightLabelText: accidentDate, rightSubLabelText: accidentTime)
        summaryRows.append(accidentDateTimeRow)
        
        // Details
		if let details = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "accidentDetails.additionalDetails"), !details.isEmpty {
			let detailsRow = SummaryRow(type: .details, leftLabelText: NSLocalizedString("claimreview.details", comment: "Details"), rightLabelText: details, rightSubLabelText: nil)
			summaryRows.append(detailsRow)
		}
		
        // Header: Vehicles involved
        let headerRow2 = SummaryRow(type: .header, leftLabelText: NSLocalizedString("claimreview.vehiclesinvolved", comment: "Vehicles involved"), rightLabelText: "", rightSubLabelText: nil)
        summaryRows.append(headerRow2)
        
        // My vehicle
		let myVehiclePredicate: NSPredicate = NSPredicate(format: "indexInClaim == %@ && claim == %@", NSNumber(value: 1), activeClaim)
		let myVehicles = (FNOLVehicle.mr_findAll(with: myVehiclePredicate) as? [FNOLVehicle]) ?? []
		if myVehicles.count > 0 {
			let myVehicle = myVehicles.first!
			let myVehicleYear = myVehicle.year ?? ""
			let myVehicleMake = myVehicle.make ?? ""
			let myVehicleModel = myVehicle.model ?? ""
			let rightMyVehicleLabelText = "\(myVehicleYear) \(myVehicleMake) \(myVehicleModel)".lowercased().capitalized
			var rightMyVehicleSubLabelText = ""
			
			if myVehicle.licensePlate != nil && myVehicle.licensePlate!.count > 0 {
				rightMyVehicleSubLabelText += "License plate: \(myVehicle.licensePlate!)"
			}
			if myVehicle.colour != nil && myVehicle.colour!.count > 0 {
				rightMyVehicleSubLabelText += "\nColor: \(myVehicle.colour!)"
			}
			let myVehicleRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("claimreview.myvehicle", comment: "My vehicle"), rightLabelText: rightMyVehicleLabelText, rightSubLabelText: rightMyVehicleSubLabelText)
			summaryRows.append(myVehicleRow)
			
			// Drivable?
			if let myVehicleDrivable = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "myVehicle.vehicleConditionAndLocation.canVehicleSafelyDiven"), !myVehicleDrivable.isEmpty {
				let myVehicleDrivableRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("claimreview.drivable", comment: "Drivable?"), rightLabelText: myVehicleDrivable, rightSubLabelText: nil)
				summaryRows.append(myVehicleDrivableRow)
			}
			
			// Driver
			if let myVehicleDriver = myVehicle.people?.allObjects.filter({ ($0 as! FNOLPerson).isDriver == true }).first as? FNOLPerson {
				let myVehicleDriverName = "\(myVehicleDriver.firstName!) \(myVehicleDriver.lastName!)".initialCapped
				let myVehicleDriverRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("driverinfo.driver", comment: "Driver"), rightLabelText: myVehicleDriverName, rightSubLabelText: nil)
				summaryRows.append(myVehicleDriverRow)
				
				// Driver injured?
				let injured = myVehicleDriver.injured == nil ? NSLocalizedString("claimreview.unknown", comment: "Unknown") : myVehicleDriver.injured!
				let myVehicleDriverInjuredRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("driverinfo.injured", comment: "Injured?"), rightLabelText: injured, rightSubLabelText: nil)
				summaryRows.append(myVehicleDriverInjuredRow)
			} else {
				let myVehicleNoDriverRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("driverinfo.driver", comment: "Driver"), rightLabelText: NSLocalizedString("driverinfo.nodriver", comment: "No driver"), rightSubLabelText: nil)
				summaryRows.append(myVehicleNoDriverRow)
			}
			
			// Insurance (if driver is not on user's policy)
			// Note that the Questionnaire does not request the insurance company name, so we can't show that here
			if let myVehicleDriver = myVehicle.people?.allObjects.first(where: { ($0 as! FNOLPerson).isDriver == true }) as? FNOLPerson, let insurancePolicyNumber = myVehicleDriver.insurancePolicyNumber {
				let insurancePolicyNumberRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("claims.insurancepolicynumber", comment: "Insurance policy number?"), rightLabelText: insurancePolicyNumber, rightSubLabelText: nil)
				summaryRows.append(insurancePolicyNumberRow)
			}
			
			// Passengers
			if let passengers = myVehicle.people?.allObjects.filter({ ($0 as! FNOLPerson).isPassenger == true }) as? [FNOLPerson] {
				for passenger in passengers {
					if let passengerFirstName = passenger.firstName, let passengerLastName = passenger.lastName {
						let passengerNameRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("claimreview.passenger", comment: "Passenger"), rightLabelText: "\(passengerFirstName) \(passengerLastName)", rightSubLabelText: nil)
						summaryRows.append(passengerNameRow)
					}
					if let passengerInjured = passenger.injured {
						let passengerInjuredRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("driverinfo.injured", comment: "Injured?"), rightLabelText: passengerInjured, rightSubLabelText: nil)
						summaryRows.append(passengerInjuredRow)
					}
				}
			}
		}
		
		
        // Other vehicles
        // TODO: Figure out whether to populate this from CD objects or responseKeys
        let otherVehiclesPredicate: NSPredicate = NSPredicate(format: "indexInClaim > %@ && claim == %@", NSNumber(value: 1), activeClaim)
        let otherVehicles = (FNOLVehicle.mr_findAll(with: otherVehiclesPredicate) as? [FNOLVehicle]) ?? []
        var vehicleNumber = 2
        for otherVehicle in otherVehicles {

			// Add other vehicle
            let vehicleYear = otherVehicle.year ?? ""
            let vehicleMake = otherVehicle.make ?? ""
            let vehicleModel = otherVehicle.model ?? ""
            let rightVehicleLabelText = "\(vehicleYear) \(vehicleMake) \(vehicleModel)".trimmingCharacters(in: .whitespaces).lowercased().capitalized
            let otherVehicleRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("claimreview.vehicle", comment: "My vehicle") + " \(vehicleNumber)", rightLabelText: rightVehicleLabelText, rightSubLabelText: "")
            summaryRows.append(otherVehicleRow)
            vehicleNumber += 1
			
			// Add other vehicle driver
			var otherVehicleDriver: FNOLPerson?
			if let driver = otherVehicle.people?.allObjects.filter({ ($0 as! FNOLPerson).isDriver == true }).first as? FNOLPerson {
				otherVehicleDriver = driver
				let driverName = "\(driver.firstName ?? "") \(driver.lastName ?? "")".initialCapped
				let otherVehicleDriverRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("driverinfo.driver", comment: "Driver"), rightLabelText: driverName, rightSubLabelText: nil)
				summaryRows.append(otherVehicleDriverRow)
			} else {
				let otherVehicleNoDriverRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("driverinfo.driver", comment: "Driver"), rightLabelText: NSLocalizedString("driverinfo.nodriver", comment: "No driver"), rightSubLabelText: nil)
				summaryRows.append(otherVehicleNoDriverRow)
			}
			
			// Add other vehicle passengers
			if let passengers = otherVehicle.people?.allObjects as? [FNOLPerson] {
				for passenger in passengers {
					if otherVehicleDriver == nil || passenger != otherVehicleDriver! {
						
						// Passenger name row
						let passengerName = "\(passenger.firstName ?? "") \(passenger.lastName ?? "")".initialCapped
						let otherVehiclePassengerRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("claimreview.passenger", comment: "Passenger"), rightLabelText: passengerName, rightSubLabelText: nil)
						summaryRows.append(otherVehiclePassengerRow)

						// Passenger injured? row
						let otherVehiclePassengerInjuredRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("driverinfo.injured", comment: "Injured?"), rightLabelText: passenger.injured ?? NSLocalizedString("claimreview.unknown", comment: "Unknown"), rightSubLabelText: nil)
						summaryRows.append(otherVehiclePassengerInjuredRow)
					}
				}
			}
        }
        
        // Header: Other people
        let headerRow3 = SummaryRow(type: .header, leftLabelText: NSLocalizedString("driverinfo.otherpeopleinvolved", comment: "Other people involved"), rightLabelText: "", rightSubLabelText: nil)
        summaryRows.append(headerRow3)
        
        // Other person
        let otherPeoplePredicate: NSPredicate = NSPredicate(format: "claim == %@", activeClaim)
        var otherPeople = (FNOLPerson.mr_findAll(with: otherPeoplePredicate) as? [FNOLPerson]) ?? []
		otherPeople = otherPeople.filter({ $0.isInAccident == true && $0.isOther == true })
        for (index, person) in otherPeople.enumerated() {
            let rightOtherPersonLabelText = "\(person.firstName ?? "") \(person.lastName ?? "")".trimmingCharacters(in: .whitespaces).initialCapped
			var rightOtherPersonSubLabelText = ""
			if let injured = person.injured {
				rightOtherPersonSubLabelText = NSLocalizedString("driverinfo.injured", comment: "Injured?") + " \(injured)"
			}
            let otherPersonRow = SummaryRow(type: .body, leftLabelText: NSLocalizedString("claimreview.person", comment: "Person") + " \(index + 1)", rightLabelText: rightOtherPersonLabelText, rightSubLabelText: rightOtherPersonSubLabelText)
            summaryRows.append(otherPersonRow)
        }
	}
}

extension ClaimReviewVC: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return summaryRows.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let summaryRow = summaryRows[indexPath.row]
		switch summaryRow.type {
		case .header:
			if let cell = tableView.dequeueReusableCell(withIdentifier: ClaimSummaryHeaderCell.identifier, for: indexPath) as? ClaimSummaryHeaderCell {
				cell.row = summaryRow
				return cell
			}
		case .body:
			if let cell = tableView.dequeueReusableCell(withIdentifier: ClaimSummaryBasicCell.identifier, for: indexPath) as? ClaimSummaryBasicCell {
				cell.row = summaryRow
				return cell
			}
		case .details:
			if let cell = tableView.dequeueReusableCell(withIdentifier: ClaimSummaryDetailsCell.identifier, for: indexPath) as? ClaimSummaryDetailsCell {
				cell.row = summaryRow
				return cell
			}
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return defaultFooterHeight
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let  footerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableFooterView.identifier) as! TableFooterView
		footerCell.delegate = self
		footerCell.nextButtonText = NSLocalizedString("footer.submitclaim", comment: "Submit claim")
		return footerCell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = summaryRows[indexPath.row]
		if row.type == .header {
			if row.leftLabelText?.lowercased().range(of: "accident") != nil {
				// User tapped "The accident" header
				for vc in navigationController!.viewControllers {
					if vc is AccidentDetailsContainerVC {
						navigationController?.popToViewController(vc, animated: true)
					}
				}
			} else if row.leftLabelText?.lowercased().range(of: "vehicle") != nil {
				// User tapped "Vehicles involved" header
				for vc in navigationController!.viewControllers {
					if vc is VehiclesContainerVC {
						navigationController?.popToViewController(vc, animated: true)
					}
				}
			} else if row.leftLabelText?.lowercased().range(of: "people") != nil {
				// User tapped "Other people involved" header
				for vc in navigationController!.viewControllers {
					if vc is OtherPeopleVC {
						navigationController?.popToViewController(vc, animated: true)
					}
				}
			}
		}
	}
	
}

extension ClaimReviewVC: FooterDelegate, ClaimNavigatable {
	func didTouchLeftButton() {
		showSaveQuitActionSheet()
		
        // Handles removing the top-bar when user navigates back
        if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
            self.supplementalNavigationController?.removeSupplementalView(topBarView, animated: false)
        }
	}
	
	func didTouchRightButton() {
		PersistenceManager.shared.saveToPersistentStore()
		askToSubmitClaim(claim: ApplicationContext.shared.fnolClaimsManager.activeClaim!)
	}

}

extension ClaimReviewVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}
