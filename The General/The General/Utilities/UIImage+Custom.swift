//
//  UIImage+Custom.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 11/27/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

extension UIImage {
	
	func resizedTo(shortestSide: CGFloat) -> UIImage? {
		let resizeWidth = size.height > size.width
		let scale = shortestSide / (resizeWidth ? size.width : size.height)
		var width: CGFloat!
		var height: CGFloat!
		if resizeWidth {
			width = shortestSide
			height = size.height * scale
		} else {
			width = size.width * scale
			height = shortestSide
		}
		UIGraphicsBeginImageContext(CGSize(width: width, height: height))
		self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return resizedImage
	}

}
