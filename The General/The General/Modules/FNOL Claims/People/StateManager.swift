//
//  StateManager.swift
//  The General
//
//  Created by Trevor Alyn on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

// TODO: Remove. TEMPORORARY CLASS.
class StateManager: NSObject {

	static let instance = StateManager()
	
	public var currentVehicle = 0
	public var owners = [DriverInfo]()
	public var drivers = [DriverInfo]()
	public var passengers = [[DriverInfo]]()
	public var otherPeople = [[DriverInfo]]()
	public var driverInfoField: Field?
	public var otherPeopleInfoField: Field?
	public var viewModel: Questionnaire? {
		didSet {
			getDriverInfoField()
			getOtherPeopleInfoField()
		}
	}
	
	// Because we don't have insurance info in the Owner fields
	private func getDriverInfoField() {
		if let viewModel = viewModel {
			for page in viewModel.pagesArray! {
				if page.pageId == "my_vehicle_people_details" {
					if let sectionsArray = page.sectionsArray {
						for section in sectionsArray {
							if section.sectionOrder == 1 {
								for field in section.fieldsArray! {
									if field.responseKey == "myVehicle.driver.whoWasDriving" {
										driverInfoField = field
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	private func getOtherPeopleInfoField() {
		if let viewModel = viewModel {
			for page in viewModel.pagesArray! {
				if page.pageId == "other_people_involved" {
					if let sectionsArray = page.sectionsArray {
						for section in sectionsArray {
							if section.sectionOrder == 0 {
								for field in section.fieldsArray! {
									if field.type == "addPersonButton" {
										otherPeopleInfoField = field
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
}
