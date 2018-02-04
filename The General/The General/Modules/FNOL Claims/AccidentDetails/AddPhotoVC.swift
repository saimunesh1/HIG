//
//  AddPhotoVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/25/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AddPhotoVC: PhotoPickViewController {
    
    @IBOutlet var takePictureButton: UIButton!

    var delegate: PickerDelegate?
    var currentField: Field?

    @IBAction func didTouchOnTakePicture(_ sender: Any) {
       
        let alert: UIAlertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let messageFont = [NSAttributedStringKey.font: UIFont.boldTitle]
        let messageAttrString = NSMutableAttributedString(string: NSLocalizedString("alert.accident.title", comment: ""), attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        let cameraAction = UIAlertAction(title: NSLocalizedString("alert.accident.camera", comment: ""), style: UIAlertActionStyle.default){[weak self] UIAlertAction in
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showPhotoPreviewVC") {
            let vc = segue.destination as! PhotoPreviewVC
            vc.delegate = self.delegate
        }
    }
    
    @objc override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		picker.dismiss(animated: true) { [weak self] in
			guard let weakSelf = self else { return }
			if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
				ApplicationContext.shared.fnolClaimsManager.activeClaim?.addImage(selectedImage, forResponseKey: "accidentDetails.accidentPictures")
				if picker.sourceType == .camera {
					UIImageWriteToSavedPhotosAlbum(selectedImage, weakSelf, #selector(weakSelf.image(_: didFinishSavingWithError: contextInfo: )), nil)
				}
			}
			weakSelf.performSegue(withIdentifier: "showPhotoPreviewVC", sender: weakSelf)
		}
    }

}

extension AddPhotoVC: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}
