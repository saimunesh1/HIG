//
//  SupportVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/24/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import SafariServices

public enum SupportViewMode {
    case standard
    case child
}

public enum SupportCallType: String {
	case claims
	case customerService
	case sales
}

public enum CallBackStatus: String {
	case initialization = "Initialization"
	case scheduled = "Scheduled"
	case pending = "Pending"
	case callingTarget = "Calling Target"
	case holding = "Holding"
	case callingClient = "Calling Client"
	case callInProgress = "Call In Progress"
	case errorCallback = "Error Callback"
	case success = "Success"
	case canceled = "Canceled"
	case failed = "Failed"
	case deleted = "Deleted"
}

class SupportVC: BaseVC {
	
	private enum SupportCellType {
		case callback
		case helpCenterButton
		case otherButtons
		case text
		case contextualHelp
		case header
	}
	
	private struct SupportCellModel {
		let type: SupportCellType
		let labelText: String?
		let supplementalLabelText: String?
	}

	@IBOutlet weak var tableView: UITableView!
	
	public static let callBackUserDefaultsKey = "callBackUserDefaultsKey"

    public var viewMode: SupportViewMode = .standard {
        didSet {
            updateViewMode()
        }
    }

	// If you're segueing to this page from a (?) icon and you want to show specific contextual help, pass it as this value
	// in prepareForSegue in the source page. The UI will update automatically.
	public var contextualHelpString: String?
	
	private var callBackButtonCanBeEnabled = false
	private var callBacksSalesAvailable = false
	private var callBacksCustomerServiceAvailable = false
	private var callBackTimeWindowsSales = [CallBackTimeWindow]()
	private var callBackTimeWindowsCustomerService = [CallBackTimeWindow]()
	private var callCenterEndTimeString = ""
	private var callCenterStartTimeString = ""
	private let chatUrl = URL(string: "https://thegeneralauto.egain.cloud/system/templates/chat/TheGeneral/index.html?entryPointId=1014&templateName=TheGeneral&locale=en-US&ver=v11&postChatAttributes=false")!
	private let helpCenterUrl = URL(string: "https://thegeneralauto.egain.cloud/system/templates/selfservice/thegeneral/help/customer/locale/en-US/portal/307700000001001")!
	private var supportCellModels = [SupportCellModel]()
	private var selectedCallType: SupportCallType?
	
	// This is not currently used, but I'm leaving it here in case holidays are eventually included in the response to the /3.0/profile/{profile_sid}/scheduling call.
	// If that happens, set this to true.
	private let useSchedulingSettings = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		checkForCallBackAvailability()
		setUpCallBackTimeWindows(callType: .customerService)
		setUpCallBackTimeWindows(callType: .sales)
		tableView.dataSource = self
		tableView.delegate = self
        
        updateViewMode()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setUpCellModels()
	}
	
    private func updateViewMode() {
        switch viewMode {
        case .standard:
            tableView?.isScrollEnabled = true
        case .child:
            tableView?.isScrollEnabled = false
        }
    }
    
	private func checkForCallBackAvailability() {
		ApplicationContext.shared.supportManager.requestCallCenterHours { [weak self](innerClosure) in

			guard let `self` = self else { return }

			guard let response = try? innerClosure() else { return }
			guard let entries = response.entries else { return }
			let todayDayOfWeek = NSCalendar.current.component(.weekday, from: Date())
			for entry in entries {
				if let daysOfWeek = entry.dayOfWeek {
					for dayOfWeek in daysOfWeek {
						if dayOfWeek == todayDayOfWeek {
							let dateFormatter = DateFormatter.hoursMilitary
							
							// There may be multiple start and end times (for example, if there's a lunch break in the middle of the day)
							if let startTimeStrings = entry.startTime, let endTimeStrings = entry.endTime, startTimeStrings.count == endTimeStrings.count {
								
								// Get today's start and end dates for "Request Callback" button
								if let startTimeString = startTimeStrings.first, let endTimeString = endTimeStrings.last, let startTime = dateFormatter.date(from: startTimeString), let endTime = dateFormatter.date(from: endTimeString) {
									let humanReadableDateFormatter = DateFormatter.hoursCivilian
									humanReadableDateFormatter.timeZone = NSTimeZone.local
									self.callCenterStartTimeString = dateFormatter.string(from: startTime)
									self.callCenterEndTimeString = dateFormatter.string(from: endTime)
								}
								
								// Figure out whether we can enable "Request Callback" button right now
								if self.useSchedulingSettings {
									for t in 0..<startTimeStrings.count {
										if var startTime = dateFormatter.date(from: startTimeStrings[t]), var endTime = dateFormatter.date(from: endTimeStrings[t]) {
											startTime = startTime.withTodaysYearMonthDay()!
											endTime = endTime.withTodaysYearMonthDay()!
											let now = Date()
											if startTime <= now && endTime > now {
												self.callBackButtonCanBeEnabled = true // Not currently used
												self.tableView.reloadData()
												break
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
	}
	
	private func setUpCallBackTimeWindows(callType: SupportCallType) {
		ApplicationContext.shared.supportManager.requestCallBackTimeWindows(type: callType) { [weak self] (innerClosure) in
			guard let `self` = self else { return }
			switch callType {
			case .customerService:
				self.callBackTimeWindowsCustomerService = [CallBackTimeWindow]()
				self.callBackTimeWindowsCustomerService.append(CallBackTimeWindow(humanReadableDescription: "Right Now", startTime: nil, endTime: nil))
			case .sales:
				self.callBackTimeWindowsSales = [CallBackTimeWindow]()
				self.callBackTimeWindowsSales.append(CallBackTimeWindow(humanReadableDescription: "Right Now", startTime: nil, endTime: nil))
			default: break
			}
			if let response = try? innerClosure() {
				if let schedule = response.schedule {
					let callbackDateFormatter = DateFormatter.callbackDateFormatter
					let humanReadableDateFormatter = DateFormatter.hoursCivilian
					humanReadableDateFormatter.timeZone = NSTimeZone.local
					for window in schedule {
						if let start = window.startTime, let end = window.endTime, let startTime = callbackDateFormatter.date(from: start), let endTime = callbackDateFormatter.date(from: end) {
							let startTimeString = humanReadableDateFormatter.string(from: startTime)
							let endTimeString = humanReadableDateFormatter.string(from: endTime)
							let callBackTimeWindow = CallBackTimeWindow(humanReadableDescription: "\(startTimeString) - \(endTimeString)", startTime: startTime, endTime: endTime)
							switch callType {
							case .customerService: self.callBackTimeWindowsCustomerService.append(callBackTimeWindow)
							case .sales: self.callBackTimeWindowsSales.append(callBackTimeWindow)
							default: break
							}
						}
					}
					self.tableView.reloadData()
				}
			} else {
				let alertController = UIAlertController(title: "", message: NSLocalizedString("support.unalbetoretrievecallbackwindows", comment: "Unable to retrieve callback windows."), preferredStyle: .alert)
				let okAction = UIAlertAction(title: NSLocalizedString( "alert.ok", comment: ""), style: .cancel, handler: nil)
				alertController.addAction(okAction)
				self.present(alertController, animated: true, completion: nil)
			}
		}
	}
	
	private func setUpCellModels() {
        if viewMode == .child {
            supportCellModels = [
                SupportCellModel(type: .otherButtons, labelText: nil, supplementalLabelText: nil)
            ]
            
            tableView.reloadData()
        } else if let _ = contextualHelpString {
			supportCellModels = [
				SupportCellModel(type: .contextualHelp, labelText: nil, supplementalLabelText: nil),
				SupportCellModel(type: .helpCenterButton, labelText: nil, supplementalLabelText: nil),
				SupportCellModel(type: .header, labelText: "Contact us", supplementalLabelText: nil),
				SupportCellModel(type: .otherButtons, labelText: nil, supplementalLabelText: nil)]
			tableView.reloadData()
		} else {
			supportCellModels = [
				SupportCellModel(type: .header, labelText: NSLocalizedString("support.heretohelp", comment: "We're here to help"), supplementalLabelText: nil),
				SupportCellModel(type: .text, labelText: NSLocalizedString("support.ifyouhaveaquestion", comment: "If you have a question or need more information, we're ready to help. Check out the Help Center or contact us through one of the methods below."), supplementalLabelText: nil),
				SupportCellModel(type: .otherButtons, labelText: nil, supplementalLabelText: nil)]
        }
        // Check to see if we have a call-back scheduled
        if let sid = UserDefaults.standard.string(forKey: SupportVC.callBackUserDefaultsKey) {
            LoadingView.show()
            ApplicationContext.shared.supportManager.getCallBackStatus(sid: sid) { [weak self] (innerClosure) in
                LoadingView.hide()
                guard let `self` = self else { return }
                guard let response = try? innerClosure() else { self.setUpHelpCenterModels(); return }
                guard let statusString = response.status, let status = CallBackStatus(rawValue: statusString) else { self.setUpHelpCenterModels(); return }
                switch status {
                case .scheduled, .success:
                    if let startDateString = response.startDate {
                        let dateFormatter = DateFormatter.callbackDateFormatter
                        if let startDate = dateFormatter.date(from: startDateString) {
                            // If call back is in the past, invalidate it
                            if startDate < Date() {
                                UserDefaults.standard.set(nil, forKey: SupportVC.callBackUserDefaultsKey)
                            } else { // Show the callback
                                // The "duration" parameter returned by the server has a value of zero, so hardcoding this to 30 minutes
                                let endDate = startDate.addingTimeInterval(60 * 30) // 30 minutes later
                                let civilianDateFormatter = DateFormatter.hoursCivilian
                                let startDateString = civilianDateFormatter.string(from: startDate)
                                let endDateString = civilianDateFormatter.string(from: endDate)
                                
                                // Get the phone number from local storage, encrypted, because service doesn't return it
                                let number = SessionManager.callBackPhoneNumber ?? ""
                                let callBackModel = SupportCellModel(type: .callback, labelText: number, supplementalLabelText: "\(startDateString) to \(endDateString)")
                                self.supportCellModels.append(callBackModel)
                                self.setUpHelpCenterModels()
                                self.tableView.reloadData()
                            }
                        }
                    }
                case .errorCallback, .canceled, .failed, .deleted:
                    UserDefaults.standard.set(nil, forKey: SupportVC.callBackUserDefaultsKey)
                    self.setUpHelpCenterModels()
                default:
                    self.setUpHelpCenterModels()
                }
            }
        } else { // No call-back found
            setUpHelpCenterModels()
        }
	}
	
	private func setUpHelpCenterModels() {
		supportCellModels += [SupportCellModel(type: .text, labelText: NSLocalizedString("support.theanswer", comment: "The answer could be in our most frequently asked questions section. Check it out."), supplementalLabelText: nil),
							  SupportCellModel(type: .helpCenterButton, labelText: nil, supplementalLabelText: nil)]
	}
	
	
	// MARK: - UI actions
	
	private func showCallUsActionSheet() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let claimsAction = UIAlertAction(title: NSLocalizedString("support.claims", comment: "Claims"), style: .default, handler: { (action) in
			ApplicationContext.shared.phoneCallManager.callClaimsNumber()
		})
		let customerServiceAction = UIAlertAction(title: NSLocalizedString("support.customerservice", comment: "Customer Service"), style: .default, handler: { (action) in
			ApplicationContext.shared.phoneCallManager.callCustomerServiceNumber()
		})
		let salesAction = UIAlertAction(title: NSLocalizedString("support.sales", comment: "Sales"), style: .default, handler: { (action) in
			ApplicationContext.shared.phoneCallManager.callSalesNumber()
		})
		if let _ = SessionManager.policyNumber { // Logged in
			alertController.addAction(customerServiceAction)
			alertController.addAction(claimsAction)
			alertController.addAction(salesAction)
		} else { // Not logged in
			alertController.addAction(salesAction)
 			alertController.addAction(claimsAction)
			alertController.addAction(customerServiceAction)
		}
		alertController.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", comment: "Cancel"), style: .cancel, handler: nil))
		present(alertController, animated: true, completion: nil)
	}
	
	private func showScheduleACallBackActionSheet() {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		// Only show Customer Service option if we have Customer Service windows available
		var customerServiceAction: UIAlertAction?
		if callBackTimeWindowsCustomerService.count > 0 {
			customerServiceAction = UIAlertAction(title: NSLocalizedString("support.customerservice", comment: "Customer Service"), style: .default, handler: { (action) in
				self.selectedCallType = .customerService
				self.performSegue(withIdentifier: "showSupportScheduleACallVC", sender: nil)
			})
		}

		// Only show Sales option if we have Sales windows available
		var salesAction: UIAlertAction?
		if callBackTimeWindowsSales.count > 0 {
			salesAction = UIAlertAction(title: NSLocalizedString("support.sales", comment: "Sales"), style: .default, handler: { (action) in
				self.selectedCallType = .sales
				self.performSegue(withIdentifier: "showSupportScheduleACallVC", sender: nil)
			})
		}
		if let _ = SessionManager.policyNumber { // Logged in
			if let customerServiceAction = customerServiceAction { alertController.addAction(customerServiceAction) }
			if let salesAction = salesAction { alertController.addAction(salesAction) }
		} else { // Not logged in
			if let salesAction = salesAction { alertController.addAction(salesAction) }
			if let customerServiceAction = customerServiceAction { alertController.addAction(customerServiceAction) }
		}
		alertController.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", comment: "Cancel"), style: .cancel, handler: nil))
		present(alertController, animated: true, completion: nil)
	}
	
	private func showChat() {
		if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
			let safariViewController = SFSafariViewController(url: chatUrl)
			safariViewController.delegate = self
			rootViewController.present(safariViewController, animated: true, completion: nil)
		}
	}
	
	private func showHelpCenter() {
		if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
			let safariViewController = SFSafariViewController(url: helpCenterUrl)
			safariViewController.delegate = self
			rootViewController.present(safariViewController, animated: true, completion: nil)
		}
	}
	
	private func cancelCall() {
		if let sid = UserDefaults.standard.string(forKey: SupportVC.callBackUserDefaultsKey) {
			let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
			alertController.addAction(UIAlertAction(title: NSLocalizedString("support.cancelscheduledcall", comment: "Cancel scheduled call"), style: .default, handler: { [weak self] (action) in
				guard let `self` = self else { return }
				LoadingView.show()
				ApplicationContext.shared.supportManager.cancelCallBack(sid: sid) { (innerClosure) in
					LoadingView.hide()
					if let _ = try? innerClosure() { // Cancellation successful
						SessionManager.callBackPhoneNumber = nil
						self.supportCellModels = self.supportCellModels.filter({ $0.type != .callback })
						self.tableView.reloadData()
					} else {
						// TODO: What if it fails?
					}
				}
			}))
			alertController.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", comment: "Cancel"), style: .cancel, handler: nil))
			present(alertController, animated: true, completion: nil)
		}
	}
	
	
	// MARK: - Segues
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showSupportScheduleACallVC", let vc = segue.destination as? SupportScheduleACallVC {
			guard let selectedCallType = selectedCallType else { return }
			vc.callType = selectedCallType
			switch selectedCallType {
			case .customerService: vc.callBackTimeWindows = callBackTimeWindowsCustomerService
			case .sales: vc.callBackTimeWindows = callBackTimeWindowsSales
			default: break
			}
		}
	}
	
}

extension SupportVC: SupplementalNavigationControllerProtocol {
	
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
	
}

extension SupportVC: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return supportCellModels.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellModel = supportCellModels[indexPath.row]
		switch cellModel.type {
		case .header:
			let cell = tableView.dequeueReusableCell(withIdentifier: SupportHeaderCell.identifier, for: indexPath) as! SupportHeaderCell
			cell.headerLabel.text = cellModel.labelText
			return cell
		case .text:
			let cell = tableView.dequeueReusableCell(withIdentifier: SupportTextCell.identifier, for: indexPath) as! SupportTextCell
			cell.centeredTextLabel?.text = cellModel.labelText
			return cell
		case .helpCenterButton:
			let cell = tableView.dequeueReusableCell(withIdentifier: SupportButtonsCell.identifier, for: indexPath) as! SupportButtonsCell
			cell.type = .helpCenter
			cell.delegate = self
			return cell
		case .otherButtons:
			let cell = tableView.dequeueReusableCell(withIdentifier: SupportButtonsCell.identifier, for: indexPath) as! SupportButtonsCell
			cell.type = .otherButtons
			cell.callCenterStartTimeString = callCenterStartTimeString
			cell.callCenterEndTimeString = callCenterEndTimeString
			cell.delegate = self
			return cell
		case .callback:
			let cell = tableView.dequeueReusableCell(withIdentifier: SupportCallBackCell.identifier, for: indexPath) as! SupportCallBackCell
			cell.phoneNumberLabel.text = cellModel.labelText
			cell.timeLabel.text = cellModel.supplementalLabelText
			cell.delegate = self
			return cell
		case .contextualHelp:
			let cell = tableView.dequeueReusableCell(withIdentifier: SupportContextualHelpCell.identifier, for: indexPath) as! SupportContextualHelpCell
			if let contextualHelpString = contextualHelpString {
				cell.contextualHelpString = contextualHelpString
			}
			return cell
		}
	}
	
}

extension SupportVC: SupportCallbackCellDelegate {
	
	func didPressCancelCall() {
		cancelCall()
	}
	
}

extension SupportVC: SFSafariViewControllerDelegate {
	
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
		if !didLoadSuccessfully {
			controller.dismiss(animated: true, completion: {
				// TODO: What if it fails?
			})
		}
	}
	
}

extension SupportVC: SupportButtonsCellDelegate {
	
	func didTap(cell: SupportButtonCell) {
		switch cell.type {
		case .callBack:
			showScheduleACallBackActionSheet()
		case .callUs:
			showCallUsActionSheet()
		case .chat:
			showChat()
		case .email:
			break
		case .helpCenter:
			showHelpCenter()
		}
	}
	
}
