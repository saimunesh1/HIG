//
//  FNOLOnboardingVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/8/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

let fnolCardsList = [
    OnboardingCard(cellID: SafetyCollectionViewCell.identifier, type: .safetyFirst),
    OnboardingCard(cellID: PhotosCollectionViewCell.identifier, type: .capturePhoto),
    OnboardingCard(cellID: InfoCollectionViewCell.identifier, type: .getInfo),
    OnboardingCard(cellID: ProcessCollectionViewCell.identifier, type: .processClaim),
    OnboardingCard(cellID: ProgressCollectionViewCell.identifier, type: .trackProgress)
]

protocol FNOLOnboardingDelegate {
    func didTouchOnEmergencyBtn()
    func didTouchOnTakePictures()
    func didTouchOnAddPictures()
}

class FNOLOnboardingVC: PhotoPickViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: OnboardingCollectionView!
    fileprivate var cardCollection = [OnboardingCard]()
    @IBOutlet weak var startClaimBtn: UIButton!
    @IBOutlet var pageControl: UIPageControl!
    
    var isUserAtScene: Bool = false
    var viewModel: Questionnaire!
    
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
        
        self.viewModel = ApplicationContext.shared.fnolClaimsManager.activeQuestionnaire
        self.setupLayout()
        guard let userSelectionValue = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "claim.atScene") else {
            return
        }
        self.isUserAtScene = userSelectionValue.lowercased() == "yes" ? true : false
        self.cardCollection = self.getList(isUserAtScene: self.isUserAtScene)
        pageControl.numberOfPages = cardCollection.count
        pageControl.currentPage = 0
        self.currentPage = 0
        self.automaticallyAdjustsScrollViewInsets = false
		startClaimBtn.backgroundColor = .tgGreen
        startClaimBtn.titleLabel?.minimumScaleFactor = 0.5
        startClaimBtn.titleLabel?.numberOfLines = 1
        startClaimBtn.titleLabel?.adjustsFontSizeToFitWidth = true
		NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: NSNotification.Name(rawValue: "statusBarFrameChanged"), object: nil)
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
    
	@IBAction func didTouchStartClaim(_ sender: Any) {
        let preQuestionnaire = PolicePreQuestionnaireVC.instantiate()
        preQuestionnaire.currentSection = self.viewModel.getPageForId(id: "getting_started")?.getCurrentSection()
        
		StateManager.instance.viewModel = viewModel
        self.navigationController?.pushViewController(preQuestionnaire, animated: true)
    }
    
    static func instantiate() -> FNOLOnboardingVC {
        let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! FNOLOnboardingVC
        return vc
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! OnboardingFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        self.pageControl.currentPage = currentPage
        
    }
    
    fileprivate func getList(isUserAtScene: Bool) -> [OnboardingCard] {
        return isUserAtScene ? fnolCardsList : fnolCardsList.filter({$0.type != .safetyFirst})
    }
	
	@objc func reloadCollectionView() {
		let rootPoint = CGPoint(x: collectionView.frame.size.width / 2.0, y: collectionView.frame.size.height / 2.0)
		let collectionViewPoint = view.convert(rootPoint, to: collectionView)
		let indexPath = collectionView.indexPathForItem(at: collectionViewPoint)!
		collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
	}
    
    @objc override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        if picker.sourceType == .camera {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_: didFinishSavingWithError: contextInfo: )), nil)
        }
        picker.dismiss(animated: true, completion: nil)
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? SupportVC {
			vc.contextualHelpString = NSLocalizedString("contextualhelp.beforeyoustartaclaim", comment: "")
		}
	}
    
}

extension FNOLOnboardingVC: FNOLOnboardingDelegate, UIPageViewControllerDelegate {
    /// On 911
    ///
    func didTouchOnEmergencyBtn() {
 
        if let url = URL(string: "tel://\(911)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func didTouchOnAddPictures() {
        self.cameraAllowsAccessToApplicationCheck()
    }
    
    func didTouchOnTakePictures() {
        self.cameraAllowsAccessToApplicationCheck()
    }
    
}

extension FNOLOnboardingVC {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardCollection.count
    }
    
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let card = cardCollection[(indexPath as NSIndexPath).row] as OnboardingCard
		switch card.type {
		case .safetyFirst:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: card.cellID, for: indexPath) as! SafetyCollectionViewCell
			cell.actionDelegate = self
			cell.cardButton.isHidden = !self.isUserAtScene
			cell.cellType = card.type
			return cell
			
		case .capturePhoto:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: card.cellID, for: indexPath) as! PhotosCollectionViewCell
			cell.actionDelegate = self
			cell.contentLabel.text = !isUserAtScene ? NSLocalizedString("onboarding.text.addingphotos", comment:"") : NSLocalizedString("onboarding.text.capturephoto", comment:"")
			cell.cardButton.isHidden = !self.isUserAtScene
			cell.cellType = card.type
			return cell
			
		case .getInfo:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: card.cellID, for: indexPath) as! InfoCollectionViewCell
			cell.actionDelegate = self
			cell.titleLabel.text = !isUserAtScene ? NSLocalizedString("onboarding.title.moreinfo", comment:"") : NSLocalizedString("onboarding.title.gatherinfo", comment:"")
			cell.contentLabel.text = !isUserAtScene ? NSLocalizedString("onboarding.text.moreinfo", comment:"") : NSLocalizedString("onboarding.text.getinfo", comment:"")
			cell.cardButton.isHidden = !self.isUserAtScene
			cell.cellType = card.type
			return cell
			
		case .processClaim:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: card.cellID, for: indexPath) as! ProcessCollectionViewCell
			cell.cellType = card.type
			return cell
			
		case .trackProgress:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: card.cellID, for: indexPath) as! ProgressCollectionViewCell
			cell.cellType = card.type
			return cell
			
		default:()
			
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
        startClaimBtn.layer.cornerRadius = 20
        startClaimBtn.clipsToBounds = true
        let layout = self.collectionView.collectionViewLayout as! OnboardingFlowLayout
        layout.spacingMode = CollectionFlowLayoutSpacingMode.overlap(visibleOffset: 10)
    }
    
	func registerNibs() {
		self.collectionView.register(SafetyCollectionViewCell.nib, forCellWithReuseIdentifier: SafetyCollectionViewCell.identifier)
		self.collectionView.register(PhotosCollectionViewCell.nib, forCellWithReuseIdentifier: PhotosCollectionViewCell.identifier)
		self.collectionView.register(InfoCollectionViewCell.nib, forCellWithReuseIdentifier: InfoCollectionViewCell.identifier)
		self.collectionView.register(ProcessCollectionViewCell.nib, forCellWithReuseIdentifier: ProcessCollectionViewCell.identifier)
		self.collectionView.register(ProgressCollectionViewCell.nib, forCellWithReuseIdentifier: ProgressCollectionViewCell.identifier)
	}

}


extension FNOLOnboardingVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}
