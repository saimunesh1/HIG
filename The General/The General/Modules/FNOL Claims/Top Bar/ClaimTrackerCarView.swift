//
//  ClaimTrackerView.swift
//  The General
//
//  Created by Moore, Michael (US - New York) on 10/21/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimTrackerCarView: UIView {
    
    typealias CarViewActionClosure = (Int) -> Void

    @IBOutlet weak var carButton: UIButton!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var actionHandler: CarViewActionClosure?
    
    var carNumber: Int = 0 {
        didSet {
            self.carLabel.text = "\(self.carNumber)"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.fromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.fromNib()
    }

    override func draw(_ rect: CGRect) {
        carLabel.layer.cornerRadius = carLabel.frame.height / 2
        carLabel.layer.borderWidth = 2.0
        carLabel.layer.masksToBounds = true
        carLabel.layer.backgroundColor = UIColor.white.cgColor
        carLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func didTouchButton(_ sender: Any) {
        self.actionHandler?(self.carNumber)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
