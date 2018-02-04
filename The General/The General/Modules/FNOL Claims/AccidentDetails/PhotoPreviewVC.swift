//
//  PhotoPreViewVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/26/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import MagicalRecord
import CoreData

class PhotoPreviewVC: PhotoPickViewController, UICollectionViewDelegate, UICollectionViewDataSource  {

    @IBOutlet weak var collectionView: AccidentPhotosCollectionView!
	@IBOutlet weak var doneButton: CustomButton!
	@IBOutlet weak var disclaimerTextLabel: UILabel!
	@IBOutlet weak var sizeLabel: UILabel!
	
	fileprivate let sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
	var imageList = [FNOLImage]()
    fileprivate let itemsPerRow: CGFloat = 2
    var delegate: PickerDelegate?
    var currentField: Field?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        refreshList()
    }
   
    @IBAction override func goBack(segue: UIStoryboardSegue) {
        if (self.imageList.isEmpty) {
            self.navigationController?.popViewController(animated: true)
        } else {
			showConfirmAlert(message: NSLocalizedString("exit.withoutsavingpictures", comment: "Exit without saving pictures?"))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sizeLabel.text = ApplicationContext.shared.fnolClaimsManager.activeClaim?.sizeOfImages
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		scrollToLastPhotoCell()
	}
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count + 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionImageCell", for: indexPath) as! ImageCell
        //If no images hide regular and show only camera icon
        if indexPath.row == imageList.count {
            cell.damageCellLabel.text = ""
            cell.damageCellImageView.image = nil
			cell.defaultImageView.isHidden = false
            cell.removeButtonImageView.isHidden = true
            cell.defaultLabel.isHidden = false
            cell.sizeLabel.isHidden = true
            cell.damageCellImageView.layer.borderColor = UIColor.tgGray.cgColor
            cell.damageCellImageView.layer.borderWidth = 1.0
            return cell
        } else {
            //Hide camera icon and show regular image
            cell.damageCellImageView.layer.borderColor = UIColor.clear.cgColor
            cell.damageCellImageView.layer.borderWidth = 0
            cell.removeButtonImageView.isHidden = false
            cell.removeButtonImageView.tag = indexPath.row
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer: )))
            cell.removeButtonImageView.isUserInteractionEnabled = true
            cell.removeButtonImageView.addGestureRecognizer(tapGestureRecognizer)
            cell.defaultImageView.isHidden = true
            cell.defaultLabel.isHidden = true
            cell.sizeLabel.isHidden = false
            cell.damageCellImageView.image = imageList[indexPath.row].thumbnailImage
            cell.damageCellLabel.text = "Photo \(indexPath.row + 1)"
            cell.sizeLabel.text = imageList[indexPath.row].imageSizeString
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == imageList.count {
            
            let alert: UIAlertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let messageFont = [NSAttributedStringKey.font: UIFont.boldTitle]
            let messageAttrString = NSMutableAttributedString(string: NSLocalizedString("alert.accident.title", comment: ""), attributes: messageFont)
            alert.setValue(messageAttrString, forKey: "attributedMessage")
            let cameraAction = UIAlertAction(title: NSLocalizedString("alert.accident.camera", comment: ""), style: UIAlertActionStyle.default){[weak self]  UIAlertAction in
                guard let weakSelf = self else { return }
                weakSelf.cameraAllowsAccessToApplicationCheck()
            }
            let gallaryAction = UIAlertAction(title: NSLocalizedString("alert.accident.gallery", comment: ""), style: UIAlertActionStyle.default){[weak self]  UIAlertAction in
                guard let weakSelf = self else { return }
                weakSelf.photoLibraryAvailabilityCheck()
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("alert.cancel", comment: ""), style: UIAlertActionStyle.cancel){
                UIAlertAction in
            }
            
            alert.addAction(cameraAction)
            alert.addAction(gallaryAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {

        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("claims.deletephotoconfirm", comment: "Are you sure?"),
            preferredStyle: UIAlertControllerStyle.alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", comment: "Cancel"), style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.yes", comment: "Yes"), style: .cancel, handler: { [weak self] (alert) -> Void in

            guard let `self` = self else { return }

            let tappedImage = tapGestureRecognizer.view as! UIImageView
            let moImage = self.imageList[tappedImage.tag]
            // TODO: We need to also delete the entity.
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.removeFromImages(moImage)
            self.imageList.remove(at: tappedImage.tag)
            self.collectionView.reloadData()
            self.sizeLabel.text = ApplicationContext.shared.fnolClaimsManager.activeClaim?.sizeOfImages
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		picker.dismiss(animated: true) { [weak self] in
			guard let weakSelf = self else { return }
			if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
				// update picked image to claim object.
				ApplicationContext.shared.fnolClaimsManager.activeClaim?.addImage(selectedImage, forResponseKey: "accidentDetails.accidentPictures")
				weakSelf.refreshList()
				
				if picker.sourceType == .camera {
					UIImageWriteToSavedPhotosAlbum(selectedImage, weakSelf, #selector(weakSelf.image(_: didFinishSavingWithError: contextInfo: )), nil)
				}
			}
			weakSelf.sizeLabel.text = ApplicationContext.shared.fnolClaimsManager.activeClaim?.sizeOfImages
			weakSelf.collectionView.reloadData()
			weakSelf.scrollToLastPhotoCell()
		}
    }
	
	private func scrollToLastPhotoCell() {
		let lastItemIndex = collectionView.numberOfItems(inSection: 0) - 1
		collectionView.scrollToItem(at: IndexPath(item: lastItemIndex, section: 0), at: .bottom, animated: true)
	}
    
    //Refresh the list from Active claim
    func refreshList() {
        imageList = (ApplicationContext.shared.fnolClaimsManager.activeClaim?.images(forResponseKey:"accidentDetails.accidentPictures"))!
        self.collectionView.reloadData()
    }
	
	@IBAction func didPressDoneButton(_ sender: Any) {
		self.delegate?.didAccidentPhotosPicked(imageArray: self.imageList)
	}
	
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageNameLabel: UILabel!
    @IBOutlet var deleteButton: BorderUIButton!
    @IBOutlet var sizeLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 1 : 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.borderColor = UIColor.tgGreen.cgColor
        isSelected = false
    }
    
    func configurecell(image: UIImage) {
        imageView.image = image
        
    }
}

extension PhotoPreviewVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem + 24.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


extension PhotoPreviewVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}

class AccidentPhotosCollectionView: UICollectionView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 2;
        self.layer.shadowOffset =  CGSize(width: -15, height: 20)
        self.layer.shadowRadius = 15;
        self.layer.shadowOpacity = 0.1;
		
    }
    
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var damageCellImageView: UIImageView!
    @IBOutlet weak var damageCellLabel: UILabel!
    @IBOutlet weak var defaultImageView: UIImageView!
    @IBOutlet weak var defaultLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!

    @IBOutlet weak var removeButtonImageView: UIImageView!
    
}
