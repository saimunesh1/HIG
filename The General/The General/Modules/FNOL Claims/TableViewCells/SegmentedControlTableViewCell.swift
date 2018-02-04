//
//  SegmentedControlTableViewCell.swift
//  The General
//
//  Created by Michael Moore on 10/27/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol SegmentedControlTableViewCellDelegate {
	func didSwitch(index: Int, row: Row?)
    func segmentValueChanged(field: Field, value: String)
}

class SegmentedControlTableViewCell: BaseTableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellSegmentControl: CustomSegmentControl!
	
	public var delegate: SegmentedControlTableViewCellDelegate?
    var responseKey: String?
    var responseCodes: [String]?
	
	var row: Row? {
		didSet {
			guard let newRow = row else {
				return
			}
			self.cellLabel.text = newRow.value
		}
	}
    
    var field: Field? {
        didSet {
            setupCurrentField()
        }
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
		delegate?.didSwitch(index: cellSegmentControl.selectedIndex, row: row)
        if let codes = responseCodes {
            
            let code = codes[cellSegmentControl.selectedIndex]
            if let item = field {
                delegate?.segmentValueChanged(field: item, value: code)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
        
    override func prepareForReuse() {
        cellSegmentControl.selectedIndex = -1
        cellSegmentControl.items = []
        responseCodes = nil
    }
    
    func setupCurrentField() {
        
        guard let item = field else { return }
        guard let valueList = item.validValuesArray else { return }
        
        cellSegmentControl.items = valueList.map({
            (v: Value) -> String in
            if v.code == "i_don't_know" {
                return "Unsure"
            }
            return v.value!
        })
    
        responseCodes = valueList.map({
            (v: Value) -> String in
            
            return v.code!
        })
        
        if item.required {
            cellLabel.attributedText = Helper.requiredAttributedText(text: item.label ?? "")
            
        } else {
            cellLabel.text = item.label
        }
    }
}
