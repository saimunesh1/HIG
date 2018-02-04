//
//  OverlayViewController.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/18/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class OverlayViewController: UIViewController, Overlayable {

	struct Dims {
		let maskWidth: CGFloat
		let maskHeight: CGFloat
		let maskHorizontalInset: CGFloat
		let maskVerticalInset: CGFloat
	}
	
	var onDidTouchAnywhere: (() -> ())?
	var tapAnywhereGestureRecognizer: UITapGestureRecognizer?
	var dims: Dims! // Must be set in viewDidLoad
	
	@IBOutlet var darkBackgroundView: UIView!
	@IBOutlet var iconImageViews: [UIImageView]?
	@IBOutlet var accessView: UIView!
	@IBOutlet var arrowView: OverlayCurvedArrow!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupInterface()
		setupGestures()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// the circle mask on the top right corner
		let circleMaskLayer = CAShapeLayer()
		let maskRect = CGRect(
			x: view.bounds.size.width - dims.maskHorizontalInset,
			y: -dims.maskVerticalInset,
			width: dims.maskWidth,
			height: dims.maskHeight)
		let path = UIBezierPath(ovalIn: maskRect)
		path.append(UIBezierPath(rect: view.bounds))
		circleMaskLayer.path = path.cgPath
		circleMaskLayer.fillRule = kCAFillRuleEvenOdd
		
		// apply the mask to the darkened view to shine a circle through
		darkBackgroundView.layer.mask = circleMaskLayer
		
		// arrow view
		let arrowRect = CGRect(
			x: 0.0,
			y: 0.0,
			width: view.bounds.size.width,
			height: accessView.frame.origin.y)
		
		let arrowBoundingRect = CGRect(
			x: view.bounds.size.width / 2.0,
			y: (dims.maskHeight / 2.0) - dims.maskVerticalInset,
			width: (view.bounds.size.width / 2.0) - dims.maskHorizontalInset - 10.0,
			height: arrowRect.size.height - (dims.maskHeight / 2.0) + dims.maskVerticalInset - 10.0)
		
		arrowView.arrowBoundingRect = arrowBoundingRect
		arrowView.frame = arrowRect
	}
	
	@objc func didTouchAnywhere(_ sender: UIButton) {
		onDidTouchAnywhere?()
	}
}


// MARK: - Private

extension OverlayViewController {

	private func setupInterface() {
		if let iconImageViews = iconImageViews {
			for view in iconImageViews {
				view.tintColor = .white
			}
		}
	}
	
	private func setupGestures() {
		tapAnywhereGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTouchAnywhere(_:)))
		
		if let tapAnywhereGestureRecognizer = tapAnywhereGestureRecognizer {
			view.addGestureRecognizer(tapAnywhereGestureRecognizer)
		}
	}

}
