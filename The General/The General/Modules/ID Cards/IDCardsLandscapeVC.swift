//
//  IDCardsLandscapeVC.swift
//  The General
//
//  Created by Hopkinson, Todd (US - Denver) on 1/16/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class IDCardsLandscapeVC: BaseVC, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var showProofButtonView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    fileprivate var cards = [IDCard]()
    fileprivate var vehicleCount = 0
    fileprivate var driverCount = 0
    fileprivate var userLanguageSelectionIsSpanish = false
    
    @IBOutlet weak var pageControl: UIPageControl!
    fileprivate var currentPage: Int = 0
    @IBOutlet weak var cardCollectionView: IDCardCollectionView!
    @IBOutlet weak var pdfIconImageView: UIImageView!
    @IBOutlet weak var proofOfInsuranceButtonView: UIView!
    @IBOutlet weak var loginButton: CustomButton! {
        didSet {
            loginButton.isHidden = true
        }
    }
    @IBOutlet weak var primaryTextLabel: UILabel!
    @IBOutlet weak var lapsedBodyLabel: UILabel!
    @IBOutlet weak var warningImageView: UIImageView!
    
    let mainBodyText = NSLocalizedString("idcard.text.mainbody", comment: "This insurance verification may not be accepted by law...")
    let lapsedBodyText = NSLocalizedString("idcard.label.lapsedpolicybody", comment: "Your policy has been cancelled. To continue your coverage, please reinstate your policy.")
    let invalidLabel = NSLocalizedString("idcard.label.invalid", comment: "Policy is no longer valid.")
    let logInButtonTitleText = NSLocalizedString("idcard.button.loginproof", comment: "Log in to view proof of insurance")
    let reinstateButtonTitleText = NSLocalizedString("idcard.button.reinstate", comment: "Reinstate Policy")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        baseNavigationController?.showMenuButton()
        setupIDCards()
        setupLayout()
        pageControl.numberOfPages = cards.count
        pageControl.currentPage = 0
        currentPage = 0
        setupButtonViews()
        updateUI()
        
        if SessionManager.isSessionValid {
            AnalyticsManager.track(event: .idCardsWasViewedLoggedOut)
        } else {
            AnalyticsManager.track(event: .idCardsLandscapeViewed)
        }
    }
    
    func setupIDCards() {
        let policyNumber = self.policyNumber ?? ""
        LoadingView.show()
        activityIndicator.startAnimating()
        ApplicationContext.shared.idCardManager.getIDCard(policyNumber: policyNumber) { [weak self] (innerClosure) in
            LoadingView.hide()
            self?.activityIndicator.stopAnimating()
            do {
                let responseModel = try innerClosure()
                self?.cards = responseModel.cards()
                self?.driverCount = responseModel.driverCount
                self?.vehicleCount = responseModel.vehicleCount
                self?.updateUI()
            } catch {
                print("Error retrieving id card(s): \(error)")
                // TODO: Better error handling
            }
        }
    }
    
    func updateUI() {
        pageControl.numberOfPages = cards.count
        pageControl.isHidden = pageControl.numberOfPages < 2
        setupLayout()
        cardCollectionView.reloadData()
        
        primaryTextLabel.text = mainBodyText
        lapsedBodyLabel.text = lapsedBodyText
        lapsedBodyLabel.isHidden = true
        proofOfInsuranceButtonView.isHidden = false
        loginButton.isHidden = true
        
        if SessionManager.isSessionValid {
            proofOfInsuranceButtonView.isHidden = false
            loginButton.isHidden = true
        } else {
            proofOfInsuranceButtonView.isHidden = true
            loginButton.isHidden = false
        }
        
        if IDCardManager.isPolicyLapsed {
            proofOfInsuranceButtonView.isHidden = true
            loginButton.isHidden = false
            loginButton.setTitle(reinstateButtonTitleText, for: .normal)
            loginButton.titleLabel?.textAlignment = NSTextAlignment.center
            primaryTextLabel.isHidden = true
            lapsedBodyLabel.isHidden = false
            warningImageView.isHidden = false
        }
    }
    
    func setupButtonViews() {
        setupButtonAppearance(buttonView: showProofButtonView)
        let proofTap = UITapGestureRecognizer(target: self, action: #selector(didTapShowProof(_: )))
        showProofButtonView.addGestureRecognizer(proofTap)
    }
    
    func setupButtonAppearance(buttonView: UIView) {
        buttonView.layer.borderWidth = 1
        buttonView.layer.borderColor = UIColor.tgGray.cgColor
        buttonView.layer.cornerRadius = 5
        
        guard let pdfImage = pdfIconImageView.image else { return }
        let pdfTemplate = pdfImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        pdfIconImageView.image = pdfTemplate
        pdfIconImageView.tintColor = UIColor.tgGreen
        
        guard let warningImage = warningImageView.image else { return }
        let warningTemplate = warningImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        warningImageView.image = warningTemplate
        warningImageView.tintColor = UIColor.red
    }
    
    var displayPolicyNumberLabelTitle: String {
        guard let policyNumber = policyNumber else { return "" }
        let isBond = policyNumber.starts(with: "OH") || policyNumber.starts(with: "TN")
        let bond = NSLocalizedString("idcard.label.bond", comment: "Bond")
        let policy = NSLocalizedString("idcard.label.policynumber", comment: "Policy Number")
        return isBond ? bond : policy // policies in state OH or TN are to be labeled "Bond" rather than "Policy Number"
    }
    
    func displayMakeModelYear(forCard card: IDCard) -> String {
        return "\(card.make) \(card.model) \(card.year)"
    }
    
    var policyNumber: String? {
        if !SessionManager.isSessionValid && IDCardManager.isCardIDInfoCached {
            return IDCardManager.getCachedIDCardPolicyNumber()
        }
        if let policyNumber = SessionManager.policyNumber {
            return policyNumber
        }
        return nil
    }
    
    var displayPolicyNumber: String? {
        if !SessionManager.isSessionValid && IDCardManager.isCardIDInfoCached {
            if let policyNumber = IDCardManager.getCachedIDCardPolicyNumber() {
                if IDCardManager.isAllowedFullIDCardsDisplayIfLoggedOut {
                    return policyNumber // permission to see full policy number when logged out
                }
                return policyNumber.replaceEachCharacterWithXSaveLast4Digits() // censored to last 4 digits
            }
        }
        if let policyNumber = self.policyNumber {
            return policyNumber
        }
        return nil
    }
    
    func displayVin(_ vin: String) -> String {
        if SessionManager.isSessionValid { return vin }
        if IDCardManager.isAllowedFullIDCardsDisplayIfLoggedOut {
            return vin
        }
        return vin.replaceEachCharacterWithXSaveLast4Digits()
    }
    
    var displayEffectiveDates: String {
        if SessionManager.isSessionValid { return IDCardManager.effectiveDateRange }
        return IDCardManager.getCachedEffectiveDateRangeString()
    }
    
    
    // MARK: - Button Actions
    @IBAction func closeButtonAction(_ sender: Any) {
        OrientationManager.shared.dismissIDCardOverlay()
    }
    
    @objc func didTapShowProof(_ sender: UIView) {
        
        if shouldPresentLanguageSelectionActionSheet {
            showLanguageSelectionActionSheet()
        } else {
            self.presentProofOverlay()
        }
    }
    
    var shouldPresentLanguageSelectionActionSheet: Bool {
        return true // TODO: implement AC2 GEN-1079 once updated with which states
    }
    
    func showLanguageSelectionActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("idcard.action.inenglish", comment: "In English"), style: .default, handler: { (action) in
            self.userLanguageSelectionIsSpanish = false
            self.presentProofOverlay()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("idcard.action.enespanol", comment: "En español"), style: .default, handler: { (action) in
            self.userLanguageSelectionIsSpanish = true
            self.presentProofOverlay()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", comment: "Cancel"), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func presentProofOverlay() {
        guard let vc = UIStoryboard(name: "IDCards", bundle: nil).instantiateViewController(withIdentifier: "ProofOfInsuranceVC") as? ProofOfInsuranceVC else { return }
        vc.policyNumber = policyNumber
        vc.driverCount = driverCount
        vc.vehicleCount = vehicleCount
        vc.spanish = userLanguageSelectionIsSpanish
        vc.shouldShowOverlayControls = true
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didPressLogin(_ sender: Any) {
        
        if IDCardManager.isPolicyLapsed && SessionManager.isSessionValid {
            OrientationManager.shared.dismissIDCardOverlay()
            ApplicationContext.shared.navigator.replace("pgac://payments", context: nil, wrap: BaseNavigationController.self)
        } else {
            // login button is only available here when logged out thus this dismissal leads always to login
            OrientationManager.shared.dismissIDCardOverlay()
        }
    }
}


// MARK: - CardCollectionView Support
extension IDCardsLandscapeVC {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = cards[(indexPath as NSIndexPath).row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IDCardCollectionViewCell.identifier, for: indexPath) as? IDCardCollectionViewCell {
            cell.driverNameLabel.text = card.driverName
            cell.makeModelYearLabel.text = self.displayMakeModelYear(forCard: card)
            cell.vinLabel.text = displayVin(card.vin)
            cell.policyNumberLabel.text = self.displayPolicyNumberLabelTitle
            cell.policyNumberDetailLabel.text = self.displayPolicyNumber
            cell.effectiveRangeLabel.text = NSLocalizedString("idcard.label.effective", comment: "Effective")
            cell.effectiveDateRangeDetailLabel.text = displayEffectiveDates
            cell.policyNumberLabel.isHidden = false
            cell.policyNumberDetailLabel.isHidden = false
            cell.effectiveRangeLabel.isHidden = false
            cell.effectiveDateRangeDetailLabel.isHidden = false
            cell.policyNotValidLabel.isHidden = true
            
            if IDCardManager.isPolicyLapsed {
                cell.policyNumberLabel.isHidden = true
                cell.policyNumberDetailLabel.isHidden = true
                cell.effectiveRangeLabel.isHidden = true
                cell.effectiveDateRangeDetailLabel.isHidden = true
                cell.policyNotValidLabel.isHidden = false
            }

            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
    }
    
    fileprivate var pageSize: CGSize {
        let layout = self.cardCollectionView.collectionViewLayout as! IDCardsFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.cardCollectionView.collectionViewLayout as! IDCardsFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        self.pageControl.currentPage = currentPage
    }
    
    fileprivate func setupLayout() {
        let layout = self.cardCollectionView.collectionViewLayout as! IDCardsFlowLayout
        layout.spacingMode = CollectionFlowLayoutSpacingMode.overlap(visibleOffset: 30)
    }
    
    func registerNibs() {
        self.cardCollectionView.register(IDCardCollectionViewCell.nib, forCellWithReuseIdentifier: IDCardCollectionViewCell.identifier)
    }
    
}
