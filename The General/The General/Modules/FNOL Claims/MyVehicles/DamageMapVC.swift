//
//  DamageMapVC.swift
//  The General
//
//  Created by Moore, Michael (US - New York) on 10/25/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class DamageMapVC: PhotoPickViewController {
    
	@IBOutlet var damageMapImageCollection: [UIImageView]!
	@IBOutlet var damageMapLabelCollection: [UILabel]!
	@IBOutlet var mirrorImageCollection: [UIImageView]!
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var damageImagesCollectionView: UICollectionView!
	@IBOutlet weak var damageImagesCollectionViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var damageMapStackView: UIStackView!
	@IBOutlet weak var doneButton: CustomButton!
	@IBOutlet weak var driverLabel: UILabel!
	@IBOutlet weak var heightConstraint: NSLayoutConstraint!
	@IBOutlet weak var passengerLabel: UILabel!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var totalSizeLabel: UILabel!

	public var selectedParts: [FNOLDamagedPart] = []

	var tapIndex: Int?
    var viewModel: Questionnaire!
    var currentPage: Page?
    var currentField: Field?
    var values: [Value]?
    var collectionViewArray: [FNOLImage] = []{
        didSet {
            damageImagesCollectionViewHeightConstraint.constant = collectionViewArray.isEmpty ? 0 : 170
            DispatchQueue.main.async {
                self.damageImagesCollectionView.layoutIfNeeded()
                self.damageImagesCollectionView.reloadData()
            }
        }
    }

	override func viewDidLoad() {
        super.viewDidLoad()
        
        if Helper.isScalingRequired() {
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 1)
        }
        
        setupViews()
        prepareDamageMap()
        
        for imageView in damageMapImageCollection {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(partTapped(tapGestureRecognizer: )))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBAction override func goBack(segue: UIStoryboardSegue) {
        self.navigationController?.popViewController(animated: true)
        ApplicationContext.shared.fnolClaimsManager.saveActiveClaim()
    }
    
    func setupViews() {
        driverLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        passengerLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        damageMapStackView.layer.addTopBorder(color: .tgGray, thickness: 1.0)
        damageMapStackView.layer.addBottomBorder(color: .tgGray, thickness: 1.0)
        damageMapStackView.layer.addLeftBorder(color: .tgGray, thickness: 1.0)
        damageMapStackView.layer.addRightBorder(color: .tgGray, thickness: 1.0)
        damageImagesCollectionView.delegate = self
        damageImagesCollectionView.dataSource = self
        for image in mirrorImageCollection {
            image.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        damageImagesCollectionViewHeightConstraint.constant = collectionViewArray.isEmpty ? 0 : 170
    }
    
    func prepareDamageMap() {
        guard let page: Page = viewModel.getPageForId(id: "my_vehicle_details") else{
            return
        }
        currentPage = page
        guard let pageID =  currentPage?.pageId,
            let sectionList = viewModel.getSectionList(pageID: pageID),
            let currentSection = sectionList.first
            else {
                return
        }
        currentField = currentSection.getFieldForType(type:"myVehicle.vehicleDamagedPartInfos")
        title = currentField?.title
        values = currentField?.getFieldValues()
        if let fieldValues = values {
            for value in fieldValues {
                if let damagedPart = Part(rawValue: value.code ?? "") {
                    let label = damageMapLabelCollection.first { $0.tag == damagedPart.index }
                    label?.text = value.value
                }
            }
        }
        //fetch from Claim Object
        refreshList()
    }
    
    //fetch from Claim object to populate the values
    func refreshList() {
		
		// Clear the container Array
        selectedParts.removeAll()
        collectionViewArray.removeAll()

		// Fetch From CoreData
        guard let partsList =  ApplicationContext.shared.fnolClaimsManager.activeClaim?.damagedParts?.array.reversed() else { return }
        selectedParts = Array(partsList) as! [FNOLDamagedPart]
        for eachPart in selectedParts {
            guard let list: [FNOLImage] = eachPart.imagesArray?.filter({ $0.image != nil }) else { return }
            self.collectionViewArray =  self.collectionViewArray + list
        }
        for eachPart in selectedParts {
            // To handle the Tap & highlight functionality
            let part = Part(rawValue: eachPart.code ?? "")
            if isPartAlreadyAdded(part: part!) == false {
                deselectPart(partIndex: (part?.index)!)
            } else {
                highlightPart(partIndex: (part?.index)!)
            }
        }
        totalSizeLabel.text = ApplicationContext.shared.fnolClaimsManager.activeClaim?.sizeOfImages
		
		// Postponing in case we're returning from the image picker controller
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
			self?.scrollToFirstPhotoCell()
		}
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        PersistenceManager.shared.save()
        ApplicationContext.shared.fnolClaimsManager.saveActiveClaim()
		navigationController?.popViewController(animated: true)
    }
    
    // On tap of damaged part
    @objc func partTapped(tapGestureRecognizer: UITapGestureRecognizer) {
		guard let tappedImage = tapGestureRecognizer.view as? UIImageView else { return }
		guard let tappedPart = Part(index: tappedImage.tag) else { return }
        self.tapIndex = tappedPart.index

		// If the part isn't already selected, highlight it
		let selectedPart = selectedParts.first(where: { $0.code == tappedPart.rawValue })
		if selectedPart == nil {
			highlightPart(partIndex: tappedPart.index)
		}
		
		showActionSheetFor(part: Part(index: tappedImage.tag)!)
    }
    
    /// Handle the deletion of image from Damaged map
    @objc func deleteImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
		guard let tappedImage = tapGestureRecognizer.view as? UIImageView else { return }
        
        //get FNOLImage from index
        let fnolImage = collectionViewArray[tappedImage.tag] as FNOLImage
        collectionViewArray.remove(at: tappedImage.tag)
        
        // delete image from part and save
		if let selectedDamagedPart = fnolImage.damagedPart {
			if selectedParts.contains(selectedDamagedPart) {
				selectedDamagedPart.removeFromImages(fnolImage)
				if (selectedDamagedPart.images?.count ?? 0) <= 0 {
					let idx = selectedParts.index(of: selectedDamagedPart)
					selectedParts.remove(at: idx!)
					ApplicationContext.shared.fnolClaimsManager.activeClaim?.removeFromDamagedParts(selectedDamagedPart)
					fnolImage.mr_deleteEntity()
					selectedDamagedPart.mr_deleteEntity()
				}
			}
			// To handle the UI Tap & highlight functionality
			let part = Part(rawValue: selectedDamagedPart.code ?? "")
			if isPartAlreadyAdded(part: part!) == false {
				deselectPart(partIndex: (part?.index)!)
			} else {
				highlightPart(partIndex: (part?.index)!)
			}
			totalSizeLabel.text = ApplicationContext.shared.fnolClaimsManager.activeClaim?.sizeOfImages
		}
    }
    
    /// Handles the Higlighting of image when user tap on each part.
    func highlightPart(partIndex: Int) {
        let damageImage = damageMapImageCollection.first { $0.tag == partIndex }
        switch partIndex {
        case Part.driverFrontWheel.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_wheel_selected")
        case Part.driverFender.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_fender_selected")
        case Part.driverFrontDoor.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_door_front_selected")
        case Part.driverRearDoor.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_door_rear_selected")
        case Part.driverQuarterPanel.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_quarter_panel_selected")
        case Part.driverRearWheel.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_wheel_selected")
        case Part.frontBumper.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_bumper_front_selected")
        case Part.hood.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_hood_selected")
        case Part.windshield.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_windshield_selected")
        case Part.roof.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_roof_selected")
        case Part.trunk.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_trunk_selected")
        case Part.rearBumper.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_bumper_rear_selected")
        case Part.passengerFrontWheel.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_wheel_selected")
        case Part.passengerFender.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_fender_selected")
        case Part.passengerFrontDoor.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_door_front_selected")
        case Part.passengerRearDoor.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_door_rear_selected")
        case Part.passengerQuarterPanel.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_quarter_panel_selected")
        case Part.passengerRearWheel.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_wheel_selected")
        default:
            return
        }
    }
    
    /// Handles the Deselecting of image when user tap on each part.
    func deselectPart(partIndex: Int) {
        let damageImage = damageMapImageCollection.first { $0.tag == partIndex }
        switch partIndex {
        case Part.driverFrontWheel.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_wheel")
        case Part.driverFender.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_fender")
        case Part.driverFrontDoor.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_door_front")
        case Part.driverRearDoor.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_door_rear")
        case Part.driverQuarterPanel.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_quarter_panel")
        case Part.driverRearWheel.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_wheel")
        case Part.frontBumper.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_bumper_front")
        case Part.hood.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_hood")
        case Part.windshield.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_windshield")
        case Part.roof.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_roof")
        case Part.trunk.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_trunk")
        case Part.rearBumper.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_bumper_rear")
        case Part.passengerFrontWheel.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_wheel")
        case Part.passengerFender.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_fender")
        case Part.passengerFrontDoor.index:
            damageImage?.image = #imageLiteral(resourceName: "damage_map_door_front")
        case Part.passengerRearDoor.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_door_rear")
        case Part.passengerQuarterPanel.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_quarter_panel")
        case Part.passengerRearWheel.index:
            damageImage?.image =  #imageLiteral(resourceName: "damage_map_wheel")
        default:
            return
        }
    }
    
    /// Add the Damagedpart photos to cliam.
    func addSelectedPhotoToList(pImage: UIImage?) {
        
        guard let index = tapIndex else {
            return
        }
        
        switch index {
        case Part.driverFrontWheel.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode:  Part.driverFrontWheel.rawValue, damagePhoto: pImage)
            
        case Part.driverFender.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.driverFender.rawValue, damagePhoto: pImage)
            
        case Part.driverFrontDoor.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.driverFrontDoor.rawValue, damagePhoto: pImage)
            
        case Part.driverRearDoor.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.driverRearDoor.rawValue, damagePhoto: pImage)
            
        case Part.driverQuarterPanel.index:
            
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.driverQuarterPanel.rawValue, damagePhoto: pImage)
            
        case Part.driverRearWheel.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.driverRearWheel.rawValue, damagePhoto: pImage)
            
        case Part.frontBumper.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.frontBumper.rawValue, damagePhoto: pImage)
            
        case Part.hood.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.hood.rawValue, damagePhoto: pImage)
            
        case Part.windshield.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.windshield.rawValue, damagePhoto: pImage)
            
        case Part.roof.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.roof.rawValue, damagePhoto: pImage)
            
        case Part.trunk.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.trunk.rawValue, damagePhoto: pImage)
            
        case Part.rearBumper.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.rearBumper.rawValue, damagePhoto: pImage)
            
        case Part.passengerFrontWheel.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.passengerFrontWheel.rawValue, damagePhoto: pImage)
            
        case Part.passengerFender.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.passengerFender.rawValue, damagePhoto: pImage)
            
        case Part.passengerFrontDoor.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode:Part.passengerFrontDoor.rawValue, damagePhoto: pImage)
            
        case Part.passengerRearDoor.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.passengerRearDoor.rawValue, damagePhoto: pImage)
            
        case Part.passengerQuarterPanel.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.passengerQuarterPanel.rawValue, damagePhoto: pImage)
            
        case Part.passengerRearWheel.index:
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.addDamagePart(partCode: Part.passengerRearWheel.rawValue, damagePhoto: pImage)
            
        default:
            return
        }
        
        //refresh Content
        refreshList()
    }
    
    // Check whether selected damaged part has previously selected pictures
    func isPartAlreadyAdded(part: Part) -> Bool {
        return selectedParts.filter{ $0.code == part.rawValue }.count > 0
    }

    func showActionSheetFor(part: Part) {
        let alert: UIAlertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let messageFont = [NSAttributedStringKey.font: UIFont.boldTitle]
        let messageAttrString = NSMutableAttributedString(string: NSLocalizedString("alert.accident.title", comment: ""), attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
		
		let cameraAction = UIAlertAction(title: NSLocalizedString("alert.accident.camera", comment: ""), style: UIAlertActionStyle.default) { [weak self]  UIAlertAction in
            guard let weakSelf = self else { return }
            weakSelf.cameraAllowsAccessToApplicationCheck()
        }
		
		let galleryAction = UIAlertAction(title: NSLocalizedString("alert.accident.gallery", comment: ""), style: UIAlertActionStyle.default) { [weak self]  UIAlertAction in
            guard let weakSelf = self else { return }
            weakSelf.photoLibraryAvailabilityCheck()
        }
		
		// Action sheet varies depending on whether part is already selected
		let selectedPart = selectedParts.first(where: { $0.code == part.rawValue })

		var noPhotoAction: UIAlertAction?
		if selectedPart == nil {
			noPhotoAction = UIAlertAction(title: NSLocalizedString("alert.accident.nophoto", comment: "No photo"), style: UIAlertActionStyle.default) { [weak self]  UIAlertAction in
				guard let weakSelf = self else { return }
				weakSelf.onNoPhoto()
			}
		}

		var removeDamagedAreaAction: UIAlertAction?
		if let selectedPart = selectedPart {
			removeDamagedAreaAction = UIAlertAction(title: NSLocalizedString("alert.accident.removedamagedarea", comment: "Remove damaged area"), style: UIAlertActionStyle.default) { [weak self] UIAlertAction in
				guard let weakSelf = self else { return }
				weakSelf.deselectPart(partIndex: part.index)
				weakSelf.unDamagePart(part: selectedPart)
				weakSelf.damageImagesCollectionView.reloadData()
				weakSelf.refreshList()
			}
		}
		
        let cancelAction = UIAlertAction(title: NSLocalizedString("alert.cancel", comment: ""), style: UIAlertActionStyle.cancel) { [weak self]  UIAlertAction in
            guard let weakSelf = self else { return }
            if weakSelf.isPartAlreadyAdded(part: part) == false {
                weakSelf.deselectPart(partIndex: part.index)
            } else {
                weakSelf.highlightPart(partIndex: part.index)
            }
        }
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
		if selectedPart == nil {
			alert.addAction(noPhotoAction!)
		} else {
			alert.addAction(removeDamagedAreaAction!)
		}
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
	
	private func unDamagePart(part: FNOLDamagedPart) {
		// Delete all images associated with damaged part
		if let images = part.imagesArray {
			for fnolImage in images {
				fnolImage.mr_deleteEntity()
			}
		}
		
		// Delete damaged part
		let idx = selectedParts.index(of: part)
		selectedParts.remove(at: idx!)
		ApplicationContext.shared.fnolClaimsManager.activeClaim?.removeFromDamagedParts(part)
		part.mr_deleteEntity()
	}
    
    func onNoPhoto() {
        addSelectedPhotoToList(pImage: nil)
    }
    
    static func instantiate() -> DamageMapVC {
        let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! DamageMapVC
        return vc
    }
    
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        addSelectedPhotoToList(pImage: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension DamageMapVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "damageImageCell", for: indexPath) as! DamageImageCell
        let damagedImage = collectionViewArray[indexPath.row] as FNOLImage
        let imageParent = damagedImage.damagedPart
        
        cell.removeButtonImageView.isHidden = false
        cell.removeButtonImageView.tag = indexPath.row
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteImageTapped(tapGestureRecognizer: )))
        cell.removeButtonImageView.isUserInteractionEnabled = true
        cell.removeButtonImageView.addGestureRecognizer(tapGestureRecognizer)
        cell.defaultImageView.isHidden = true
        cell.defaultLabel.isHidden = true
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.borderWidth = 0
        cell.damageCellImageView.image = damagedImage.image
        cell.sizeLabel.text = damagedImage.imageSizeString
        cell.damageCellLabel.text = "\(imageParent?.code ?? "")"
        return cell
    }
	
	private func scrollToFirstPhotoCell() {
		if damageImagesCollectionView.numberOfItems(inSection: 0) > 0 {
			damageImagesCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
		}
	}
	
}

class DamageImageCell: UICollectionViewCell {
    @IBOutlet weak var damageCellImageView: UIImageView!
    @IBOutlet weak var damageCellLabel: UILabel!
    @IBOutlet weak var defaultImageView: UIImageView!
    @IBOutlet weak var defaultLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var removeButtonImageView: UIImageView!
}

extension DamageMapVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}

extension Array where Element: NSObject {
    func newArrayByCopyingItems() -> [Any] {
        return self.map { $0.copy() }
    }
}
