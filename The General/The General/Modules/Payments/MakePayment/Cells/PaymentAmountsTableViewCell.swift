//
//  PaymentAmountsTableViewCell.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/7/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PaymentAmountsTableViewCell: UITableViewCell {

	@IBOutlet weak var collectionView: UICollectionView!

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        self.collectionView.layoutIfNeeded()
        
        var collectionViewSize = self.collectionView.collectionViewLayout.collectionViewContentSize
        collectionViewSize.height = collectionViewSize.height + 32
        
        return  collectionViewSize
    }
}
