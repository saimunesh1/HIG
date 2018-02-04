//
//  InitialOnboardingVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class InitialOnboardingVC: BaseVC, UICollectionViewDelegate, UICollectionViewDataSource {
	
	@IBOutlet weak var collectionView: OnboardingCollectionView!
	@IBOutlet weak var continueButton: UIButton!
	@IBOutlet var pageControl: UIPageControl!
	@IBOutlet weak var welcomeLabelTopConstraint: NSLayoutConstraint!
	
	fileprivate var cardCollection = [OnboardingCard]()
	fileprivate var currentPage: Int = 0 {
		didSet {
			DispatchQueue.main.async{ [weak self] in
				guard let weakSelf = self else { return }
				_ = weakSelf.cardCollection[weakSelf.currentPage]
			}
		}
	}
	
	@IBAction override func goBack(segue: UIStoryboardSegue) {
		self.navigationController?.popViewController(animated: false)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		registerNibs()
		cardCollection = [
			OnboardingCard(cellID: PaymentOptionsCollectionViewCell.identifier, type: .paymentOptions),
			OnboardingCard(cellID: InsuranceVerificationCollectionViewCell.identifier, type: .insuranceVerification),
			OnboardingCard(cellID: ClaimsAndPolicyCollectionViewCell.identifier, type: .claimsAndPolicy),
			OnboardingCard(cellID: HelpCenterCollectionViewCell.identifier, type: .helpCenter)
		]
		setupLayout()
		pageControl.numberOfPages = cardCollection.count
		pageControl.currentPage = 0
		currentPage = 0
		automaticallyAdjustsScrollViewInsets = false
		continueButton.titleLabel?.minimumScaleFactor = 0.5
		continueButton.titleLabel?.numberOfLines = 1
		continueButton.titleLabel?.adjustsFontSizeToFitWidth = true
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		// Adjust location of welcome message for this screen size
		if view.bounds.size.height > 667.0 {
			welcomeLabelTopConstraint.constant = 30.0
		} else if view.bounds.size.height > 568.0 {
			welcomeLabelTopConstraint.constant = 20.0
		}
	}
	
	@IBAction func didTouchContinueButton(button: UIButton) {
		SettingsManager.firstLaunchCompleted = true
		ApplicationContext.shared.navigator.replace("pgac://login", context: nil, wrap: nil, handleDrawerController: false)
	}
	
	static func instantiate() -> InitialOnboardingVC {
		let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! InitialOnboardingVC
		return vc
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let layout = self.collectionView.collectionViewLayout as! OnboardingFlowLayout
		let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
		let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
		currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
		let buttonText = (currentPage == cardCollection.count - 1) ? NSLocalizedString("onboarding.button.continue", comment: "Continue") : NSLocalizedString("onboarding.button.skip", comment: "Skip")
		continueButton.setTitle(buttonText, for: .normal)
		self.pageControl.currentPage = currentPage
	}
	
}

extension InitialOnboardingVC {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cardCollection.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let card = cardCollection[(indexPath as NSIndexPath).row] as OnboardingCard
		var cell: OnboardingCollectionViewCell?
		switch card.type {
		case .claimsAndPolicy:
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: card.cellID, for: indexPath) as! ClaimsAndPolicyCollectionViewCell
		case .helpCenter:
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: card.cellID, for: indexPath) as! HelpCenterCollectionViewCell
		case .insuranceVerification:
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: card.cellID, for: indexPath) as! InsuranceVerificationCollectionViewCell
		case .paymentOptions:
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: card.cellID, for: indexPath) as! PaymentOptionsCollectionViewCell
		default:()
		}
		if let cell = cell {
			cell.cellType = card.type
			return cell
		}
		return UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.pageControl.currentPage = indexPath.row
	}
	
	fileprivate var pageSize: CGSize {
		let layout = self.collectionView.collectionViewLayout as! OnboardingFlowLayout
		var pageSize = layout.itemSize
		if layout.scrollDirection == .horizontal {
			pageSize.width += layout.minimumLineSpacing
		} else {
			pageSize.height += layout.minimumLineSpacing
		}
		return pageSize
	}
	
	fileprivate func setupLayout() {
		continueButton.layer.cornerRadius = 20
		continueButton.clipsToBounds = true
		let layout = self.collectionView.collectionViewLayout as! OnboardingFlowLayout
		layout.spacingMode = CollectionFlowLayoutSpacingMode.overlap(visibleOffset: 10)
	}
	
	func registerNibs() {
		self.collectionView.register(ClaimsAndPolicyCollectionViewCell.nib, forCellWithReuseIdentifier: ClaimsAndPolicyCollectionViewCell.identifier)
		self.collectionView.register(HelpCenterCollectionViewCell.nib, forCellWithReuseIdentifier: HelpCenterCollectionViewCell.identifier)
		self.collectionView.register(InsuranceVerificationCollectionViewCell.nib, forCellWithReuseIdentifier: InsuranceVerificationCollectionViewCell.identifier)
		self.collectionView.register(PaymentOptionsCollectionViewCell.nib, forCellWithReuseIdentifier: PaymentOptionsCollectionViewCell.identifier)
	}
	
}

extension InitialOnboardingVC: SupplementalNavigationControllerProtocol {
	func shouldDisplayNavigationBarSupplements() -> Bool {
		return false
	}
}
