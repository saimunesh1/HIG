//
//  SupportScheduleACallVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/29/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public struct CallBackTimeWindow {
	let humanReadableDescription: String
	let startTime: Date?
	let endTime: Date?
}

class SupportScheduleACallVC: BaseVC {
	
	private enum TableCells: Int {
		case weCallYou = 0
		case time = 1
		case timePicker = 2
		case doneButton = 3
	}
	
	@IBOutlet weak var tableView: UITableView!
	
	public var callType: SupportCallType!
	public var callBackTimeWindows: [CallBackTimeWindow]!

	private var formattedPhoneNumber = ""
	private var unformattedPhoneNumber = ""
	private var phoneNumberIsValid = false
	private var selectedCallBackTimeWindow: CallBackTimeWindow!
	private var timePickerViewExpanded = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		selectedCallBackTimeWindow = callBackTimeWindows[0]
		tableView.dataSource = self
		tableView.delegate = self
		tableView.tableFooterView = UIView() // To hide empty rows
	}
	
	@objc override func keyboardWillShow(sender: NSNotification) {
		tableView.contentInset.bottom = keyboardHeight
	}
	
	@objc override func keyboardWillHide(sender: NSNotification) {
		tableView.contentInset.bottom = 0
	}

}

extension SupportScheduleACallVC: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.row {
		case TableCells.weCallYou.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: SupportWeCallYouCell.identifier, for: indexPath) as! SupportWeCallYouCell
			cell.delegate = self
			return cell
		case TableCells.time.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: SupportCallBackTimeCell.identifier, for: indexPath) as! SupportCallBackTimeCell
			cell.delegate = self
			cell.timeLabel.text = selectedCallBackTimeWindow?.humanReadableDescription ?? "Right Now"
			return cell
		case TableCells.timePicker.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: SupportCallBackTimePickerCell.identifier, for: indexPath) as! SupportCallBackTimePickerCell
			cell.callBackTimeWindows = callBackTimeWindows
			cell.delegate = self
			return cell
		case TableCells.doneButton.rawValue:
			let cell = tableView.dequeueReusableCell(withIdentifier: SupportCallBackDoneButtonCell.identifier, for: indexPath) as! SupportCallBackDoneButtonCell
			cell.delegate = self
			cell.phoneNumberIsValid = phoneNumberIsValid
			return cell
		default:
			return UITableViewCell() // Should never be hit
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == TableCells.timePicker.rawValue && !timePickerViewExpanded {
			return 0.0
		}
		return UITableViewAutomaticDimension
	}
	
}

extension SupportScheduleACallVC: SupportWeCallYouCellDelegate {
	
	func update(phoneNumber: String) {
		unformattedPhoneNumber = phoneNumber
		phoneNumberIsValid = NumberFormatter.phoneNumber(from: unformattedPhoneNumber).count > 0
		tableView.reloadRows(at: [IndexPath(row: TableCells.doneButton.rawValue, section: 0)], with: .none)
	}
	
}

extension SupportScheduleACallVC: SupportCallBackTimeCellDelegate {
	
	func didPressTimeButton() {
		timePickerViewExpanded = !timePickerViewExpanded
		
		// Animates hiding/showing the picker row
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
}

extension SupportScheduleACallVC: SupportCallBackTimePickerCellDelegate {
	
	func didSelect(callBackTimeWindow: CallBackTimeWindow) {
		selectedCallBackTimeWindow = callBackTimeWindow
		tableView.reloadRows(at: [IndexPath(row: TableCells.time.rawValue, section: 0)], with: .none)
	}

}

extension SupportScheduleACallVC: SupportCallBackDoneButtonCellDelegate {
	
	func didPressDone() {
		var number = unformattedPhoneNumber
		if number.count == 10 {
			// Add a leading 1 because the API requires it
			number = "1\(unformattedPhoneNumber)"
		}
		// Save phone number to local storage, encrypted, because service doesn't return it
		SessionManager.callBackPhoneNumber = number
		if let callBackTime = selectedCallBackTimeWindow.startTime {
			LoadingView.show()
			ApplicationContext.shared.supportManager.requestCallBack(type: callType, number: number, time: callBackTime, completion: { [weak self] (innerClosure) in
				LoadingView.hide()
				guard let weakSelf = self else { return }
				if let response = try? innerClosure() {
					// TODO: Do we need to do anything with response.status?
					if let sid = response.sid {
						UserDefaults.standard.set(sid, forKey: SupportVC.callBackUserDefaultsKey)
					}
					weakSelf.goBack()
				} else {
					weakSelf.showErrorAlert()
				}
			})
		} else { // No call-back time, so don't pass one
			LoadingView.show()
			ApplicationContext.shared.supportManager.requestCallBack(type: callType, number: number, time: nil, completion: { [weak self] (innerClosure) in
				LoadingView.hide()
				guard let weakSelf = self else { return }
				if let response = try? innerClosure() {
					// TODO: Do we need to do anything with response.status?
					if let sid = response.sid {
						UserDefaults.standard.set(sid, forKey: SupportVC.callBackUserDefaultsKey)
					}
					weakSelf.goBack()
				} else {
					weakSelf.showErrorAlert()
				}
			})
		}
	}
	
	func showErrorAlert() {
		let alertController = UIAlertController(title: "", message: NSLocalizedString("support.unabletoschedulecallback", comment: "Unable to schedule callback."), preferredStyle: .alert)
		let okAction = UIAlertAction(title: NSLocalizedString( "alert.ok", comment: ""), style: .cancel, handler: nil)
		alertController.addAction(okAction)
		self.present(alertController, animated: true, completion: nil)
	}

}
