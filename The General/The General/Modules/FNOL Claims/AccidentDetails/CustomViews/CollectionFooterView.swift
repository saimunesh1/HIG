//
//  CollectionFooterView.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/3/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class CollectionFooterView: UICollectionReusableView {
    
    var callback: ((String) -> ())?

    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var doneButton: CustomButton!
    @IBOutlet var sizeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    @IBAction func didTouchOnDone(_ sender: Any) {
        callback?("Done")
        
    }
}
