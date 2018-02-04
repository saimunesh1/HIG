//
//  SeverityDamageCell.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 11/2/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation
import UIKit

public enum DamageSeverity: String {
	case minor = "MINOR"
	case moderate = "MODERATE"
	case severe = "SEVERE"
	static let allValues = [minor.rawValue, moderate.rawValue, severe.rawValue]
}

class SeverityDamageCell: UITableViewCell {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var titleLabel: UILabel!
    var callback: ((String) -> ())?
    
    var indexNumber = -1


    let damageTypes = ["Minor", "Moderate", "Severe"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: width / 2, height: width / 2)
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension SeverityDamageCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return damageTypes.count        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! PreviewCollectionCell
        cell.collectionImageView.image = UIImage(named: damageTypes[indexPath.row])
        if indexNumber == indexPath.row {
             cell.checkImageView.isHidden = false
        }else{
             cell.checkImageView.isHidden = true
        }
        //Severity cell
        switch indexPath.row {
        case 0:
            cell.collectionImageTitleLbl.text = NSLocalizedString("severity.minor", comment:"Minor")
            cell.severityContentLabel.text = NSLocalizedString("severity.minor.text", comment:"Small Dents and scratches")
        case 1:
            cell.collectionImageTitleLbl.text = NSLocalizedString("severity.moderate", comment:"Moderate")
            cell.severityContentLabel.text = NSLocalizedString("severity.moderate.text", comment:"Significant damage on the exterior")
        case 2:
            cell.collectionImageTitleLbl.text = NSLocalizedString("severity.severe", comment:"Severe")
            cell.severityContentLabel.text = NSLocalizedString("severity.severe.text", comment:"Extreme damage to most of the vehicle.")
            
        default:()
            
        }
        return cell
    }
    
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionCell
		indexNumber = indexPath.row
		self.callback!(DamageSeverity.allValues[indexPath.row])
		cell?.checkImageView.isHidden = false
	}

     func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionCell
        cell?.checkImageView.isHidden = true
    }

}

extension SeverityDamageCell: UICollectionViewDelegateFlowLayout {
    
    fileprivate var sectionInsets: UIEdgeInsets {
        return .zero
    }
    
    fileprivate var itemsPerRow: CGFloat {
        return 2
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    
    fileprivate var interitemSpace: CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionPadding = sectionInsets.left * (itemsPerRow + 1)
        let interitemPadding = max(0.0, itemsPerRow - 1) * interitemSpace
        let availableWidth = collectionView.bounds.width - sectionPadding - interitemPadding
        return CGSize(width: availableWidth / 3, height: 205.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interitemSpace
    }
}
