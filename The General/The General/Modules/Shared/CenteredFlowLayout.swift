//
//  SupportButtonsCellFlowLayout.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class CenteredFlowLayout: UICollectionViewFlowLayout {

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard var elementAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
		guard elementAttributes.count > 0 else { return elementAttributes }
		elementAttributes = elementAttributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
		let minY = elementAttributes.last!.frame.minY
		let lastRowAttrs = elementAttributes.reversed().filter { $0.frame.minY == minY }
		guard lastRowAttrs.count < 3,
			let first = elementAttributes.first,
			let last = elementAttributes.last else {
				return elementAttributes
		}
		let horizontalPadding = rect.width - first.frame.minX - last.frame.maxX
		let horizontalShift = horizontalPadding / 2.0
		for attrs in lastRowAttrs {
			attrs.frame = attrs.frame.offsetBy(dx: horizontalShift, dy: 0)
		}
		return elementAttributes
	}

}
