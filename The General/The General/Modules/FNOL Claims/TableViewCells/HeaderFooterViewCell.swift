//
//  HeaderFooterViewCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/30/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class HeaderFooterViewCell: BaseTableViewHeaderFooterView {
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet weak var cellSegmentControl: CustomSegmentControl!
	
    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cellSegmentControl.selectedIndex = 1
    }

	@IBAction func segmentValueChanged(_ sender: Any) {
        _ = delegate?.toggleSection(self.section)

    }
    
    func setCollapsed(_ collapsed: Bool) {
        
    }
}
