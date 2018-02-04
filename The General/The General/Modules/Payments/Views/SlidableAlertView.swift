//
//  SlidableAlertView.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 12/14/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

enum SlidableAlertType {
    case positive
    case attention
    case failure
    case update
}

// Discussion: Ideal for display via SupplimentalNavigationController
//
class SlidableAlertView: UIView {
    
    
    // MARK: - Interface
    open class func create(withTitle title: String? = nil, withMessage message: String, type: SlidableAlertType) -> SlidableAlertView {
        
        let view = Bundle.main.loadNibNamed("SlidableAlertView", owner: nil, options: nil)?.first as! SlidableAlertView
        
        view.title = title
        view.message = message
        view.type = type
    
        return view
    }
    
    var type: SlidableAlertType = .positive {
        didSet {
            self.updateView()
        }
    }
    
    var title: String? {
        didSet {
            self.updateView()
        }
    }
    
    var message: String? {
        didSet {
            self.updateView()
        }
    }
    
    var desiredHeight: CGFloat {
        get {
            self.layoutIfNeeded()
            let kBottomBuffer: CGFloat = 20
            return self.messageLabel.frame.maxY + kBottomBuffer
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: self.frame.size.width, height: self.desiredHeight)
        }
    }
    
    
    // MARK: - Private
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        self.updateView()
    }
    
    fileprivate func updateView() {
        
        self.titleLabel?.text = title
        
        self.messageLabel?.text = message
        
        switch self.type {
            
        case .positive:
            imageView.image = UIImage(named: "24px__check")
            imageView.tintColor = UIColor.tgGreen
            
        case .attention:
            imageView.image = UIImage(named: "16px_warning")
            imageView.tintColor = UIColor.tgOrange
            
        case .failure:
            imageView.image = UIImage(named: "24px_x")
            imageView.tintColor = UIColor.tgRed
        case .update:
            imageView.image = UIImage(named: "24px__check")
            imageView.tintColor = .white
            backgroundColor = UIColor.tgGreen
            self.messageLabel?.textColor = .white
        }
        
        
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.desiredHeight)
    }
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var messageLabel: UILabel!
}
