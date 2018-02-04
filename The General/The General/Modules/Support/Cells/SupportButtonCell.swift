//
//  SupportButtonCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

public enum SupportButtonCellType {
	case helpCenter
	case chat
	case email
	case callUs
	case callBack
}

protocol SupportButtonCellDelegate: class {
	func didTap(cell: SupportButtonCell)
}

class SupportButtonCell: UICollectionViewCell {
    
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var label: UILabel!
	
	public var type = SupportButtonCellType.helpCenter { didSet { update() } }
	public weak var delegate: SupportButtonCellDelegate?
	public var callCenterStartTimeString: String?
	public var callCenterEndTimeString: String?

	private var isTappable = true

	override func awakeFromNib() {
		super.awakeFromNib()
		layer.borderWidth = 1.0
		layer.borderColor = UIColor.tgGray.cgColor
		label.textColor = .tgTextFontColor
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
	}
	
	private func update() {
		var callCenterStartTime: Date?
		var callCenterEndTime: Date?
		var callCenterStartTimeString: String?
		var callCenterEndTimeString: String?
		let now = Date()
		if let (start, end, _) = ApplicationContext.shared.configurationManager.callTheGeneralAndChatHours() {
			callCenterStartTime = start
			callCenterEndTime = end
			let dateFormatter = DateFormatter.hourMinuteMeridiemTimezone
			dateFormatter.timeZone = NSTimeZone.local
			callCenterStartTimeString = dateFormatter.string(from: callCenterStartTime!)
			callCenterEndTimeString = dateFormatter.string(from: callCenterEndTime!)
		}
		isTappable = false
		if type == .chat || type == .callUs || type == .callBack {
			if let start = callCenterStartTime, let end = callCenterEndTime {
				isTappable = (now >= start) && (now < end) && (!ApplicationContext.shared.configurationManager.isCallCenterHoliday(date: now))
			} else {
				isTappable = false // Don't enable button if we don't know hours
			}
		}

		switch type {
		case .helpCenter:
			isTappable = true
			imageView.image = UIImage(named: "36px_help-center")
			label.font = UIFont.alert
			label.text = NSLocalizedString("support.helpcenter", comment: "Help Center")
		case .chat:
			imageView.image = UIImage(named: "36px_chat")
			label.font = isTappable ? UIFont.alert : UIFont.textSmall
			if let callCenterStartTimeString = callCenterStartTimeString, let callCenterEndTimeString = callCenterEndTimeString, !isTappable {
				var labelString = NSLocalizedString("support.chat.disabled", comment: "Live chat available |startTime| to |endTime| on business days")
				labelString.insertString(string: callCenterStartTimeString, replacingTag: "|startTime|")
				labelString.insertString(string: callCenterEndTimeString, replacingTag: "|endTime|")
				label.text = labelString
			} else {
				label.text = NSLocalizedString("support.chat", comment: "Chat")
			}
		case .email:
			isTappable = true
			imageView.image = UIImage(named: "36px_email")
			label.font = UIFont.alert
			label.text = NSLocalizedString("support.email", comment: "Email")
		case .callUs:
			imageView.image = UIImage(named: "36px_call")
			label.font = isTappable ? UIFont.alert : UIFont.textSmall
			if let callCenterStartTimeString = callCenterStartTimeString, let callCenterEndTimeString = callCenterEndTimeString, !isTappable {
				var labelString = NSLocalizedString("support.callus.disabled", comment: "Available |startTime| to |endTime| on business days")
				labelString = String(labelString.replacingOccurrences(of: "|startTime|", with: callCenterStartTimeString))
				labelString = String(labelString.replacingOccurrences(of: "|endTime|", with: callCenterEndTimeString))
				label.text = labelString
			} else {
				label.text = NSLocalizedString("support.callus", comment: "Call us")
			}
		case .callBack:
			// TODO: Update if call is already scheduled?
			imageView.image = UIImage(named: "36px_call-back")
			label.font = isTappable ? UIFont.alert : UIFont.textSmall
			if let callCenterStartTimeString = callCenterStartTimeString, let callCenterEndTimeString = callCenterEndTimeString, !isTappable {
				var labelString = NSLocalizedString("support.callback.disabled", comment: "Callback available |startTime| to |endTime| on business days")
				labelString = String(labelString.replacingOccurrences(of: "|startTime|", with: callCenterStartTimeString))
				labelString = String(labelString.replacingOccurrences(of: "|endTime|", with: callCenterEndTimeString))
				label.text = labelString
			} else {
				label.text = NSLocalizedString("support.callback", comment: "Chat")
			}
		}
		imageView.tintColor = isTappable ? .tgGreen : .tgGray
	}
	
	@objc func didTap() {
		if isTappable {
			delegate?.didTap(cell: self)
		}
	}
	
}
