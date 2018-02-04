//
//  PreviewCollectionCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation
import UIKit

class PreviewCollectionCell: UICollectionViewCell  {
    
    @IBOutlet var collectionImageView: UIImageView!
    @IBOutlet var checkImageView: UIImageView!
    @IBOutlet var collectionImageTitleLbl: UILabel!
    @IBOutlet var severityContentLabel: UILabel!

	override func awakeFromNib() {
		collectionImageTitleLbl.textColor = UIColor.tgGreen
	}
}
