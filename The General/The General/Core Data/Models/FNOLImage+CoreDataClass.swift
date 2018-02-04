//
//  FNOLImage+CoreDataClass.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 11/5/17.
//  Copyright © 2017 The General. All rights reserved.
//
//

import Foundation
import UIKit
import CoreData
import MagicalRecord

@objc(FNOLImage)
public class FNOLImage: NSManagedObject {
    /// Generates a new UUID for the image if one doesn't exist already
    func generateImageIdIfNeeded() {
        guard self.imageId == nil else { return }
        self.imageId = UUID().uuidString
    }
    
    /// - Helpers
    var image: UIImage? {
        set {
            if newValue != nil {
				// Saving in JPEG to preserve orientation in Core Data
				self.imageData = UIImageJPEGRepresentation(newValue!, 1.0)
                self.imageSize = Int64(self.compressedImageData?.count ?? 0)
            }
            else {
                self.imageData = nil
                self.imageSize = 0
            }
        }
        get {
            guard let imageData = self.imageData else { return nil }
            return UIImage(data: imageData)
        }
    }
    
	var thumbnailImage: UIImage? {
		set {
			if newValue != nil {
				// Saving in JPEG to preserve orientation in Core Data
				self.thumbnailImageData = UIImageJPEGRepresentation(newValue!, 1.0)
				self.imageSize = Int64(self.compressedImageData?.count ?? 0)
			}
			else {
				self.imageData = nil
				self.imageSize = 0
			}
		}
		get {
			guard let thumbnailImageData = self.thumbnailImageData else { return nil }
			return UIImage(data: thumbnailImageData)
		}
	}
	
    var compressedImageData: Data? {
        guard let image = self.image else { return nil }
        return UIImageJPEGRepresentation(image, 0.8)
    }
    
    var imageSizeString: String {
        return ByteCountFormatter.file.string(fromByteCount: self.imageSize)
    }
}
