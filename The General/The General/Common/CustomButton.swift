//
//  UIColor+Custom.swift
//  The General
//
//  Created by Moore, Michael (US - New York) on 10/7/17.
//  Copyright © 2017 Deloitte Digital. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
	
	override var isEnabled: Bool {
		didSet {
			backgroundColor = isEnabled ? .tgGreen : .tgGray
		}
	}	

    func setupView() {
        layer.cornerRadius = frame.height / 2
        backgroundColor =  .tgGreen
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: 16.0)
    }
}
