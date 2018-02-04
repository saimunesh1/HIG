//
//  SupportButtonsCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

public enum SupportButtonsCellType {
	case helpCenter
	case otherButtons
}

protocol SupportButtonsCellDelegate: class {
	func didTap(cell: SupportButtonCell)
}

class SupportButtonsCell: BaseTableViewCell {
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
	
	private struct SupportButtonCellModel {
		let type: SupportButtonCellType
	}
	
	public weak var delegate: SupportButtonsCellDelegate?
	public var type = SupportButtonsCellType.helpCenter { didSet { update() } }
	public var callCenterStartTimeString: String?
	public var callCenterEndTimeString: String?

	private let cellHeight: CGFloat = 100.0
	private var cellModels = [SupportButtonCellModel]()
	private let itemsPerRow: CGFloat = 2
	private let inset: CGFloat = 6.0
	private var sectionInsets: UIEdgeInsets!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.collectionViewLayout = CenteredFlowLayout()
		sectionInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
	}

	private func update() {
		switch type {
		case .helpCenter:
			cellModels = [SupportButtonCellModel(type: .helpCenter)]
			collectionViewHeightConstraint.constant = cellHeight + sectionInsets.top + sectionInsets.bottom
		case .otherButtons:
			collectionViewHeightConstraint.constant = (cellHeight * 2) + (sectionInsets.top + sectionInsets.bottom) * 2
			cellModels = [SupportButtonCellModel(type: .chat), SupportButtonCellModel(type: .email), SupportButtonCellModel(type: .callUs), SupportButtonCellModel(type: .callBack)]
		}
		collectionView.reloadData()
	}

}

extension SupportButtonsCell: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cellModels.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SupportButtonCell", for: indexPath) as! SupportButtonCell
		cell.type = cellModels[indexPath.row].type
		cell.delegate = self
		cell.callCenterStartTimeString = callCenterStartTimeString
		cell.callCenterEndTimeString = callCenterEndTimeString
		return cell
	}

}

extension SupportButtonsCell: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
		let availableWidth = collectionView.bounds.width - inset - paddingSpace
		let widthPerItem = availableWidth / itemsPerRow
		return CGSize(width: widthPerItem, height: cellHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return sectionInsets
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return sectionInsets.bottom * 2.0
	}
	
}

extension SupportButtonsCell: SupportButtonCellDelegate {
	
	func didTap(cell: SupportButtonCell) {
		delegate?.didTap(cell: cell)
	}
	
}
