//
//  TopBar.swift
//  The General
//
//  Created by Moore, Michael (US - New York) on 10/18/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

enum FNOLTopBarPageType: Equatable {
    case accidentDetails
    case vehicle(number: Int)
    case otherPeople
    
    static func ==(lhs: FNOLTopBarPageType, rhs: FNOLTopBarPageType) -> Bool {
        switch lhs {
        case .accidentDetails:
            if case .accidentDetails = rhs { return true }
        case .otherPeople:
            if case .otherPeople = rhs { return true }
        case .vehicle(let number1):
            if case .vehicle(let number2) = rhs, number1 == number2 { return true }
        }
        
        return false
    }
}

protocol FNOLTopBarNavigatable {
    var pageType: FNOLTopBarPageType { get }
}

extension UIView {
    @discardableResult
    func fromNib<T: UIView>() -> T? {
        guard let contentView = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else { return nil }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear

        self.addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        return contentView
    }
}

class ClaimProcessTracker: UIView {

    @IBOutlet weak var clipboardImageView: UIImageView!
    @IBOutlet weak var line1View: UIView!
    @IBOutlet weak var line2View: UIView!
    @IBOutlet weak var carStackView: UIStackView!
    @IBOutlet weak var pedestrianImageView: UIImageView!
    @IBOutlet weak var clipboardButton: UIButton!
    weak var navigationController: UINavigationController!
    
    var carImageViews: [ClaimTrackerCarView] = []
    fileprivate(set) var currentPage: FNOLTopBarPageType = .accidentDetails

    init() {
        super.init(frame: .zero)
        self.fromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 65.0).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.fromNib()
    }
	
	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIScreen.main.bounds.width, height: 65.0)
	}

    func setupTopBar(carCount: Int) {

        pedestrianImageView.tintColor = .tgGray
        
        // Remove any existing cars
        self.carImageViews = []
        for view in self.carStackView.arrangedSubviews {
            view.removeFromSuperview()
        }

        for i in 0..<carCount {
            let newCarView = ClaimTrackerCarView()
            newCarView.carNumber = i + 1
            newCarView.carImageView.tintColor = .tgGray
            newCarView.carLabel.layer.borderColor = UIColor.tgGray.cgColor
            newCarView.carLabel.textColor = .tgGray
            
            newCarView.actionHandler = { [weak self] (carNumber) in
                self?.attemptToNavigateToPage(.vehicle(number: carNumber))
            }

            if carCount == 1 {
                newCarView.carLabel.isHidden = true
                newCarView.widthConstraint.constant = 24.0
            }

            carStackView.insertArrangedSubview(newCarView, at: i)
            carImageViews.append(newCarView)
        }
    }
    
    func setCurrentPage(_ type: FNOLTopBarPageType) {
        self.currentPage = type
        
        switch type {
        case .accidentDetails:
            self.clipboardImageView.tintColor = .tgTextFontColor
            self.clipboardButton.isEnabled = false
            self.line1View.backgroundColor = .tgGray
            for carView in self.carImageViews {
                carView.carImageView.tintColor = .tgGray
                carView.carLabel.layer.borderColor = UIColor.tgGray.cgColor
                carView.carLabel.textColor = .tgGray
            }
            self.line2View.backgroundColor = .tgGray
            self.pedestrianImageView.tintColor = .tgGray
            
        case .vehicle(let number):
            self.clipboardImageView.tintColor = .tgGreen
            self.clipboardButton.isEnabled = true
            self.line1View.backgroundColor = .tgTextFontColor
            for (index, carView) in self.carImageViews.enumerated() {
                carView.carButton.isEnabled = false
                
                var color: UIColor = .tgGray
                if index < number - 1 {
                    color = .tgGreen
                    carView.carButton.isEnabled = true
                }
                else if index == number - 1 {
                    color = .tgTextFontColor
                }
                
                carView.carImageView.tintColor = color
                carView.carLabel.layer.borderColor = color.cgColor
                carView.carLabel.textColor = color
            }
            self.line2View.backgroundColor = .tgGray
            self.pedestrianImageView.tintColor = .tgGray
            
        case .otherPeople:
            self.clipboardImageView.tintColor = .tgGreen
            self.clipboardButton.isEnabled = true
            self.line1View.backgroundColor = .tgTextFontColor
            for carView in self.carImageViews {
                carView.carButton.isEnabled = true
                carView.carImageView.tintColor = .tgGreen
                carView.carLabel.layer.borderColor = UIColor.tgGreen.cgColor
                carView.carLabel.textColor = .tgGreen
            }
            self.line2View.backgroundColor = .tgTextFontColor
            self.pedestrianImageView.tintColor = .tgTextFontColor
        }
    }
    
    @IBAction func didTouchAccidentDetails(_ sender: Any) {
        self.attemptToNavigateToPage(.accidentDetails)
    }
    
    func attemptToNavigateToPage(_ page: FNOLTopBarPageType) {
        for viewController in self.navigationController.viewControllers.reversed() {
            if let navigatable = viewController as? FNOLTopBarNavigatable {
                if navigatable.pageType == page {
                    self.navigationController.popToViewController(viewController, animated: true)
                }
            }
        }
    }
}
