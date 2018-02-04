//
//  ClaimsProgressView.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/12/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class ClaimsProgressView: UIView {
	
	private let circleSize: CGFloat = 10.0
	private var currentStep = 0
	private var backgroundLineView: UIView!
	private var foregroundLineView: UIView!
	private var backgroundCircleViews = [UIView]()
	private var foregroundCircleViews = [UIView]()
	private var foregroundLineTrailingConstraint: NSLayoutConstraint!

	public var numberOfSteps = 0 {
		didSet {
			setUpSteps(count: numberOfSteps)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setUp()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setUp()
	}
	
	private func setUp() {
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	private func setUpSteps(count: Int) {
		
		// Set up lines
		if backgroundLineView == nil {
			backgroundLineView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.width, height: 2.0))
			backgroundLineView.backgroundColor = .tgGray
			backgroundLineView.translatesAutoresizingMaskIntoConstraints = false
			foregroundLineView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.width, height: 2.0))
			foregroundLineView.backgroundColor = .tgGreen
			foregroundLineView.translatesAutoresizingMaskIntoConstraints = false
			addSubview(backgroundLineView)
			addSubview(foregroundLineView)

			var allConstraints = [NSLayoutConstraint]()
			let views = ["foregroundLineView": foregroundLineView!, "backgroundLineView": backgroundLineView!]
			let topConstraintSize = 4.0 + (circleSize / 2.0)
			let lineConstraints1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(topConstraintSize)-[backgroundLineView(2.0)]", options: [], metrics: nil, views: views)
			let lineConstraints2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundLineView]|", options: [], metrics: nil, views: views)
			let lineConstraints3 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(topConstraintSize)-[foregroundLineView(2.0)]", options: [], metrics: nil, views: views)
			let lineConstraints4 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[foregroundLineView]|", options: [], metrics: nil, views: views)
			foregroundLineTrailingConstraint = lineConstraints4[1]
			allConstraints += lineConstraints1 + lineConstraints2 + lineConstraints3 + lineConstraints4
			NSLayoutConstraint.activate(allConstraints)
		}

		// Remove existing circles (if any)
		for view in backgroundCircleViews { view.removeFromSuperview() }
		for view in foregroundCircleViews { view.removeFromSuperview() }
		backgroundCircleViews = [UIView]()
		foregroundCircleViews = [UIView]()

		// Add circles with constraints
		let leftConstraintLengthIncrement = (bounds.size.width - circleSize) / CGFloat(numberOfSteps - 1)
		for stepIndex in 0..<count {
			
			var allConstraints = [NSLayoutConstraint]()
			
			let backgroundCircleView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: circleSize, height: circleSize))
			backgroundCircleView.translatesAutoresizingMaskIntoConstraints = false
			backgroundCircleView.backgroundColor = .white
			backgroundCircleView.layer.cornerRadius = circleSize / 2.0
			backgroundCircleView.layer.borderColor = UIColor.tgGray.cgColor
			backgroundCircleView.layer.borderWidth = 2.0
			backgroundCircleViews.append(backgroundCircleView)
			addSubview(backgroundCircleView)

			let backgroundViews = ["circleView": backgroundCircleView]
			let horizontalOffset = CGFloat(stepIndex) * leftConstraintLengthIncrement
			let backgroundVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[circleView(\(circleSize))]", options: [], metrics: nil, views: backgroundViews)
			let backgroundHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(horizontalOffset)-[circleView(\(circleSize))]", options: [], metrics: nil, views: backgroundViews)
			allConstraints += backgroundVerticalConstraints
			allConstraints += backgroundHorizontalConstraints
			
			let foregroundCircleView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: circleSize, height: circleSize))
			foregroundCircleView.translatesAutoresizingMaskIntoConstraints = false
			foregroundCircleView.backgroundColor = .tgGreen
			foregroundCircleView.layer.cornerRadius = circleSize / 2.0
			foregroundCircleView.layer.masksToBounds = true
			foregroundCircleViews.append(foregroundCircleView)
			addSubview(foregroundCircleView)

			let foregroundViews = ["circleView": foregroundCircleView]
			let foregroundVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[circleView(\(circleSize))]", options: [], metrics: nil, views: foregroundViews)
			let foregroundHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[circleView(\(circleSize))]", options: [], metrics: nil, views: foregroundViews)
			allConstraints += foregroundVerticalConstraints
			allConstraints += foregroundHorizontalConstraints
			
			NSLayoutConstraint.activate(allConstraints)
		}
	}
	
	public func setCurrentStep(index: Int) {
		let rightConstraintLengthIncrement = (bounds.size.width - circleSize) / CGFloat(numberOfSteps - 1)
		// Update circles
		for i in 0..<index {
			let filteredConstraintsForThisCircleView = self.constraints.filter { $0.firstItem as! UIView === self.foregroundCircleViews[i] && $0.firstAttribute == .leading }
			if let leadingConstraint = filteredConstraintsForThisCircleView.first {
				leadingConstraint.constant = CGFloat(i) * rightConstraintLengthIncrement
			}
		}
		let endCircleView = foregroundCircleViews[index - 1]
		bringSubview(toFront: endCircleView)
		endCircleView.layer.borderColor = UIColor.tgGreen.cgColor
		endCircleView.layer.borderWidth = 2.0
		endCircleView.backgroundColor = .white

		// Update line
		self.foregroundLineTrailingConstraint.constant = CGFloat(self.numberOfSteps - index) * rightConstraintLengthIncrement
		self.layoutIfNeeded()
	}
		
}
