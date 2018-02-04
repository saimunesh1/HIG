//
//  ClaimsClaimDetailDraftCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/14/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol ClaimsClaimDetailDraftCellDelegate {
	func didTapDeleteDraft()
}

class ClaimsClaimDetailDraftCell: BaseTableViewCell {
	
	@IBOutlet var dividerViews: [UIView]!
	
	public var delegate: ClaimsClaimDetailDraftCellDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		for dividerView in dividerViews {
			dividerView.backgroundColor = .tgGray
		}
	}

	@IBAction func didPressDeleteDraft(_ sender: Any) {
		delegate?.didTapDeleteDraft()
	}
}
