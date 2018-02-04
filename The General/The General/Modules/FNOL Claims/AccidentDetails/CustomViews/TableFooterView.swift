//
//  TableFooterView.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class TableFooterView: UITableViewHeaderFooterView {
    
    var delegate: FooterDelegate?
    @IBOutlet weak var nextButton: BorderUIButton!
	@IBOutlet weak var firstButton: BorderUIButton!
    
	var firstButtonText: String = NSLocalizedString("footer.savequit", comment: "Save/Quit") {
		didSet {
			firstButton.setTitle(firstButtonText, for: .normal)
		}
	}
	
	var nextButtonText: String = NSLocalizedString("footer.nextvehicles", comment: "Next: Vehicles") {
		didSet {
			nextButton.setTitle(nextButtonText, for: .normal)
		}
	}
	
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		firstButton.borderColor = .tgGreen
		nextButton.backgroundColor = .tgGreen
	}
    
    @IBAction func touchOnLeftButton(_ sender: Any) {
        delegate?.didTouchLeftButton()
    }
    
    @IBAction func touchOnRightButton(_ sender: Any) {
        delegate?.didTouchRightButton()
    }
	
    static var identifier: String {
        return String(describing: self)
    }
}
