//
//  PhotoPickViewController.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/26/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import Photos
import CoreLocation

class PhotoPickViewController: FNOLBaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var deviceLatitude: Double = 0.0
    var deviceLongtitude: Double = 0.0
    var isLocationsAccessed: Bool = false
    
    func checkPhotos() {
        PHPhotoLibrary.requestAuthorization() { status in
            switch status {
            case .authorized:
				DispatchQueue.main.async {
					self.callSourcePicker(pickerType: .photoLibrary)
				}
            default:()
            }
        }
    }
    
    /// Determines whether app has access photos.
    ///
    /// If sunccess then launch the camera
    func checkCamera() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                      completionHandler: { (granted:Bool) -> Void in
                                        if granted {
											self.callSourcePicker(pickerType: .camera)
                                        }
                                        else {
                                            print("access denied")
                                        }
        })
    }
    
    /// Handles Grant/Deny access to Photo Library
    ///
    func photoLibraryAvailabilityCheck() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            self.callSourcePicker(pickerType: .photoLibrary)
        case .denied, .restricted :
            alertToEncouragePhotosInitially()
        case .notDetermined:
            checkPhotos()
        }
    }
    
    /// Handles Grant/Deny access to Camera
    ///
    func cameraAllowsAccessToApplicationCheck() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            checkCamera()
        case .authorized:
            self.callSourcePicker(pickerType: .camera)
        case .denied, .restricted:
            alertToEncourageCameraAccessInitially()
            
        }
    }
    
    func callSourcePicker(pickerType: UIImagePickerControllerSourceType) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = pickerType
		
		// Fixes a problem where the current VC would be removed from the view hierarchy
		// https://stackoverflow.com/questions/19890761/warning-presenting-view-controllers-on-detached-view-controllers-is-discourage
		guard let rootViewController = self.view.window?.rootViewController else { return }
		rootViewController.present(myPickerController, animated: true, completion: nil)
    }
    
    func alertToEncouragePhotosInitially() {
        let alert = UIAlertController(
            title: NSLocalizedString("alert.title", comment: ""),
            message: NSLocalizedString("permission.photos", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", comment: ""), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("permission.photos.allowAccess", comment: ""), style: .cancel, handler: { (alert) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(
            title: NSLocalizedString("alert.title", comment: ""),
            message: NSLocalizedString("permission.camera", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.cancel", comment: ""), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("permission.camera.allowAccess", comment: ""), style: .cancel, handler: { (alert) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        print(error ?? "")
    }
    
}
