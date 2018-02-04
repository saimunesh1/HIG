//
//  FNOLClaimsManger.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/6/17.
//  Copyright © 2017 Deloitte Digital. All rights reserved.
//

import UIKit
import CoreData
import MagicalRecord

class FNOLClaimsManager {
    typealias GetReferenceNumberClosure = (() throws -> String) -> Void
    typealias GetMakeClosure = (() throws -> [String]) -> Void
    typealias GetQuestionnaireClosure = (() throws -> Questionnaire? ) -> Void
    typealias SubmitClaimProgressClosure = () -> Void
    typealias SubmitClaimCompletionClosure = (() throws -> Void) -> Void

    // TODO: Fix this to deal with values "insured_vehicle_only" and "etc"
    var vehicleCount: Int {
        get {
            return Int((ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey:"claim.vehicleCount"))!)!
        }
    }
    
    // Current vehicle being worked on
	var currentVehicleIndex: Int32 = 0
    var currentVehicle: FNOLVehicle? {
		if let activeClaim = activeClaim {
			let predicate: NSPredicate = NSPredicate(format: "claim == %@", activeClaim)
			var vehicles = (FNOLVehicle.mr_findAll(with: predicate) as? [FNOLVehicle]) ?? []
			vehicles = vehicles.filter(({ $0.indexInClaim == currentVehicleIndex }))
			if vehicles.count > 1 {
				print("Error: More than one vehicle with indexInClaim == currentVehicleIndex.")
				return nil
			}
			return vehicles.first
		}
		return nil
    }
 
    /// Instance of service consumer
    let serviceConsumer = FNOLServiceConsumer()

    /// Top-bar tracking view used in the FNOL flow
    fileprivate(set) var topBarView: ClaimProcessTracker? = ClaimProcessTracker()
    
    /// Current FNOL claim being worked on
    fileprivate(set) var activeClaim: FNOLClaim?
    
    /// Current questionnaire being worked on
    fileprivate(set) var activeQuestionnaire: Questionnaire?
    
    fileprivate let submitClaimManagedObjectContext: NSManagedObjectContext = NSManagedObjectContext.mr_context(withParent: NSManagedObjectContext.mr_default())
    
    func startNewClaim() {
        self.activeQuestionnaire = self.questionnaire(forPolicy: SessionManager.policyNumber!)
        
        let claim: FNOLClaim = FNOLClaim.mr_createEntity()!
		claim.status = ClaimStatus.draftSaved.rawValue
        claim.generateLocalIdIfNeeded()
        claim.startedDate = Date()
        claim.policyNumber = SessionManager.policyNumber
        self.activeClaim = claim
    }
    
    func resumeExistingClaim(_ claim: FNOLClaim) {
        self.activeQuestionnaire = self.questionnaire(forPolicy: claim.policyNumber!)
        self.activeClaim = claim
    }
	
	func deleteActiveClaim() {
		activeClaim?.mr_deleteEntity()
		saveActiveClaim()
		activeClaim = nil
	}
    
    /// Saves all changes to the persistent store
    func saveActiveClaim() {
        PersistenceManager.shared.saveToPersistentStore()
    }
}


// MARK: - Questionnaire
extension FNOLClaimsManager {
    /// Gets the cached questionnaire from CoreData
    ///
    /// - Parameter policy: policy number
    /// - Returns: Questionnaire model
    func questionnaire(forPolicy policy: String) ->  Questionnaire? {
        let predicate = NSPredicate(format: "policyNumber = %@", policy)
        return Questionnaire.mr_findFirst(with: predicate, sortedBy: "createdDate", ascending: false)
    }
}


// MARK: - Claim Submission
extension FNOLClaimsManager {
    /// Submit a claim
    ///
    /// - Parameters:
    ///   - claim: Claim to submit
    ///   - progress: Progress of image uploads
    ///   - completion: Completion handler
    func submitClaim(_ claim: FNOLClaim, progress: SubmitClaimProgressClosure?, completion: @escaping SubmitClaimCompletionClosure) {
        // We need to get the claim into a new context to work on in the background
        let claim = claim.mr_(in: self.submitClaimManagedObjectContext)!
        
        DispatchQueue.global().async {
            // Step 1: If we don't have a reference number, we need to get one first
            if claim.referenceNumber == nil {
                self.serviceConsumer.getReferenceNumber(policyNumber: claim.policyNumber!) { (innerClosure) in
                    do {
                        let response = try innerClosure()
                        claim.referenceNumber = response.referenceNumber
                        
                        // Restart submission now that we have reference number
                        self.submitClaim(claim, progress: progress, completion: completion)
                    }
                    catch let error {
                        DispatchQueue.main.async {
                            completion({ throw error })
                        }
                    }
                }

                // Bail out, once we have a reference number we'll retry
                return
            }
            
            // Step 2: Build the claim submission body from the claim data
            let claimBody = self.buildSubmitClaimBody(withClaim: claim)
            
            // Keeps track if any processes failed...
            var failed = false
            
            // Step 3: Submit the claim
            let submitClaimSemaphore = DispatchSemaphore(value: 0)
            self.serviceConsumer.submitClaim(policyNumber: claim.policyNumber!, referenceNumber: claim.referenceNumber!, finalClaimUpload: false, claimInformation: claimBody) { (innerClosure) in
                defer {
                    submitClaimSemaphore.signal()
                }
                
                do {
                    try innerClosure()
                }
                catch {
                    failed = true
                    
                    DispatchQueue.main.async {
                        completion({ throw error })
                    }
                }
            }
            submitClaimSemaphore.wait()
            if failed { return }
            
            // Step 4: Upload the images
            if let images = claim.imagesArray, !images.isEmpty {
                let uploadImagesSemaphore = DispatchSemaphore(value: images.count)
                
                for image in images {
                    self.serviceConsumer.uploadPicture(image.image!, forId: image.imageId!, referenceNumber: claim.referenceNumber!, finalClaimUpload: false) { (innerClosure) in
                        defer {
                            uploadImagesSemaphore.signal()
                        }
                        
                        do {
                            try innerClosure()
                        }
                        catch {
                            if !failed {
                                failed = true
                            
                                DispatchQueue.main.async {
                                    completion({ throw error })
                                }
                            }
                        }
                    }
                }
                uploadImagesSemaphore.wait()
                if failed { return }
            }
            
            // Step 5: Finalize the claim
            // We do this by sending an empty uploadPicture request with finalClaimUpload set to true
            self.serviceConsumer.uploadPicturesWithIds([:], referenceNumber: claim.referenceNumber!, finalClaimUpload: true) { (innerClosure) in
                do {
                    try innerClosure()
                    
                    DispatchQueue.main.async {
                        completion({ /* Success */ })
                    }
                }
                catch {
                    DispatchQueue.main.async {
                       completion({ throw error })
                    }
                }
            }
        }
    }

    /// Generates the claim submission body from the claim
    ///
    /// - Parameter claim: Claim to used for data values
    /// - Returns: Properly formatted claim submission body
    func buildSubmitClaimBody(withClaim claim: FNOLClaim) -> [String: Any] {
        var claimBody: [String: Any] = [:]
        
        // Damaged Parts
        if let damagedParts = claim.damagedPartsArray, !damagedParts.isEmpty {
            var finalDamagedParts: [[String: Any]] = []
            
            for damagedPart in damagedParts {
                var finalDamagedPart: [String: Any] = [
                    "type": damagedPart.code!
                ]
                
                if let damagedPartImages = damagedPart.imagesArray {
                    let imageIds = damagedPartImages.map({ $0.imageId! })
                    finalDamagedPart["pictureIds"] = imageIds
                }
                
                finalDamagedParts.append(finalDamagedPart)
            }
            
            claimBody.set(finalDamagedParts, forKeyPath: "myVehicle.vehicleDamagedPartInfos")
        }
		
		// Accident photos
		if let accidentPhotos = claim.imagesArray, !accidentPhotos.isEmpty {
			var photoIdArray = [String]()
			
			// Omit photos of damaged parts
			for accidentPhoto in accidentPhotos.filter({ $0.responseKey == "accidentDetails.accidentPictures" }) {
				if let imageId = accidentPhoto.imageId {
					photoIdArray.append(imageId)
				}
			}
			claimBody.set(photoIdArray, forKeyPath: "accidentDetails.pictureIds")
		}
		
		let predicate: NSPredicate = NSPredicate(format: "claim == %@", claim)
		let fnolVehicles = (FNOLVehicle.mr_findAll(with: predicate) as? [FNOLVehicle]) ?? []
		
		 // My vehicle
		if let myVehicle = fnolVehicles.first(where: { $0.indexInClaim == 1 }) { // My vehicle
			if let colour = myVehicle.colour { claimBody.set(colour, forKeyPath: "myVehicle.vehicleInfo.color") }
			if let licensePlate = myVehicle.licensePlate { claimBody.set(licensePlate, forKeyPath: "myVehicle.vehicleInfo.licensePlate") }
			if let licensePlateImageId = myVehicle.licensePlateImage?.imageId { claimBody.set(licensePlateImageId, forKeyPath: "myVehicle.vehicleInfo.licensePlateImage") }
			if let make = myVehicle.make { claimBody.set(make, forKeyPath: "myVehicle.vehicleInfo.make") }
			if let model = myVehicle.model { claimBody.set(model, forKeyPath: "myVehicle.vehicleInfo.model") }
			if let vin = myVehicle.vin { claimBody.set(vin, forKeyPath: "myVehicle.vehicleInfo.vin") }
			if let year = myVehicle.year { claimBody.set(year, forKeyPath: "myVehicle.vehicleInfo.year") }
			
			if let people = myVehicle.people?.allObjects as? [FNOLPerson] {
	
				// Owner
				if let owner = people.first(where: { $0.vehicle == myVehicle && $0.isOwner == true }) {
					let ownerDict = owner.asDictionary()
					claimBody.set(ownerDict, forKeyPath: "myVehicle.ownerContact")
				}

				// Driver
				if let driver = people.first(where: { $0.vehicle == myVehicle && $0.isDriver == true }) {
					let driverDict = driver.asDictionary()
					claimBody.set(driverDict, forKeyPath: "myVehicle.driver")
				}
				
				// Passengers
				let passengers = people.filter({ $0.vehicle == myVehicle && $0.isPassenger == true })
				if passengers.count > 0 {
					var passengersDict = [Any]()
					passengers.forEach({ (passenger) in
						let passengerDict = passenger.asDictionary()
						passengersDict.append(passengerDict)
					})
					claimBody.set(passengersDict, forKeyPath: "myVehicle.passengers")
				}
			}
		}
		
		// Other vehicles
		let otherFnolVehicles = fnolVehicles.filter({ $0.indexInClaim > 1 })
		var otherVehiclesArray = [Any]()
		for vehicle in otherFnolVehicles {
			
			// This should automatically include the owner, driver, and passengers
			otherVehiclesArray.append(vehicle.asDictionary())
		}
		let otherVehiclesObject = ["otherVehicles": otherVehiclesArray]

		// Other people involved
		let fnolPeople = (FNOLPerson.mr_findAll(with: predicate) as? [FNOLPerson]) ?? []
		let otherFnolPeople = fnolPeople.filter({ $0.isOther == true })
		var otherPeopleArray = [Any]()
		for person in otherFnolPeople {
			var personDict = [String: Any]()
			if let firstName = person.firstName { personDict["firstName"] = firstName }
			if let lastName = person.lastName { personDict["lastName"] = lastName }
			if let addressDetail1 = person.addressDetail1 { personDict["addressDetail1"] = addressDetail1 }
			if let addressDetail2 = person.addressDetail2 { personDict["addressDetail2"] = addressDetail2 }
			if let city = person.city { personDict["city"] = city }
			if let state = person.state { personDict["state"] = state }
			if let zip = person.zip { personDict["zip"] = zip }
			if let country = person.country { personDict["country"] = country }
			if let phoneNumber = person.phoneNumber { personDict["phoneNumber"] = phoneNumber }
			if let injured = person.injured { personDict["injured"] = injured }
			if let injuryType = person.injuryType { personDict["injuryType"] = injuryType }
			if let injuryDetails = person.injuryDetails { personDict["injuryDescription"] = injuryDetails }
			if let transportedFromScene = person.transportedFromScene { personDict["transportedFromScene"] = transportedFromScene }
			if let isWitness = person.isWitness { personDict["isThisPersonWitness"] = isWitness }
			if let pictureId = person.licenseImage?.imageId { personDict["pictureId"] = pictureId }
			otherPeopleArray.append(personDict)
		}
		let otherPeopleObject = ["contacts": otherPeopleArray]

        // Go through the remaining responses and put their values at the expanded keypath
        if let responses = claim.responsesArray {
			let responseKeysToIgnore = ["otherVehicle", "otherVehicles[x]"]
            for response in responses {
                guard let responseKey = response.responseKey, let responseValue = response.value else { continue }
				// Ignore response keys for elements that are handled from Core Data up above
				let ignore = responseKeysToIgnore.contains(where: { responseKey.range(of: $0 + ".") != nil })
				if !ignore {
					print("Setting \(responseKey) to \(responseValue)")
					claimBody.set(responseValue, forKeyPath: responseKey)
				}
            }
			// Manually insert other vehicles, other people
			claimBody.set(otherVehiclesObject, forKeyPath: "otherVehicles")
			claimBody.set(otherPeopleObject, forKeyPath: "people")
        }
		return claimBody
    }
}


// MARK: - Services: Questionnaire
extension FNOLClaimsManager {
    /// Request a Questionnaire number to start FNOL process.
    ///
    /// - Parameters:
    ///   - policyNumber: Account holder's policy number
    ///   - completion: Completion block
    func getQuestionnaire(forPolicy policy: String, completion: @escaping GetQuestionnaireClosure) {
        
        self.serviceConsumer.getQuestionnaire(policyNumber: policy) { (innerClosure) in
            do {
                let responseModel = try innerClosure()
                
                MagicalRecord.save({ (context) in
                    let questionnaire: Questionnaire = Questionnaire.mr_createEntity(in: context)!
                    questionnaire.createdDate = Date()
                    questionnaire.policyNumber = policy
                    questionnaire.populate(fromResponse: responseModel, inContext: context)
                }, completion: { (sucecss, error) in
                    DispatchQueue.main.async {
                        completion({ [weak self] in
                            self?.questionnaire(forPolicy: policy)
                        })
                    }
                })
            }
            catch {
                completion({ throw error })
            }
        }
    }
    
    
    /// Get list of available car makes for a given year.
    ///
    /// - Parameters:
    ///   - year: Year of car
    ///   - completion: Completion handler
    func getMakesForYear(year: String, completion: @escaping GetMakeClosure) {
        self.serviceConsumer.getMakesForYear(year: year) { (innerClosure) in
            do {
                let responseModel = try innerClosure()
                completion({ return responseModel})
            }
            catch let error {
                completion({ throw error })
            }
        }
    }
    
    
    /// Get list of available models for a given make and year.
    ///
    /// - Parameters:
    ///   - make: Make of car
    ///   - year: Year of car
    ///   - completion: Completion handler
    func getModelsForMakesYear(make: String, year: String, completion: @escaping GetMakeClosure) {
        self.serviceConsumer.getModelsForMakesYear(make: make, year: year) { (innerClosure) in
            do {
                let responseModel = try innerClosure()
                completion({ return responseModel})
            }
            catch let error {
                completion({ throw error })
            }
        }
    }
}
