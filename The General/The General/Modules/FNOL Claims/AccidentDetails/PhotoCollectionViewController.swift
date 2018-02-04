//
//  PhotoCollectionViewController.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/25/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "accidentCell"
fileprivate let takeBtnIdentifier = "takePictureCell"

struct PhotoItem {
    let name: String
    let pictures: [AccidentPicture]
}

class PhotoCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var pickedImage: UIImage?

    @IBOutlet var collectionView: UICollectionView!
    fileprivate let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    var imageList = [PhotoItem]()
    fileprivate let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(TakeButtonCell.self, forCellWithReuseIdentifier: takeBtnIdentifier)
    }
    
    @IBAction func goBack(segue: UIStoryboardSegue) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return imageList[section].pictures.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! AccidentPictureCell
            let picture = photoForIndexPath(indexPath)
            guard let img = picture.thumbnail as UIImage? else {
                return cell
            }
            cell.imageView = UIImageView(image:img)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == self.imageList.count - 1 {
            
        }
    }

    @IBAction func didTouchOnDone(_ sender: Any) {
        let vcIndex = self.navigationController?.viewControllers.index(where: { (viewController) -> Bool in
            if let _ = viewController as? AccidentDetailsContainerViewController {
                return true
            }
            return false
        })
        
        let destination = self.navigationController?.viewControllers[vcIndex!] as! AccidentDetailsContainerViewController
        self.navigationController?.popToViewController(destination, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

private extension PhotoCollectionViewController {
    func photoForIndexPath(_ indexPath: IndexPath) -> AccidentPicture {
        return imageList[(indexPath as NSIndexPath).section].pictures[(indexPath as NSIndexPath).row]
    }
}

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
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

extension PhotoCollectionViewController: SupplementalNavigationControllerProtocol {
    func shouldDisplayNavigationBarSupplements() -> Bool {
        return false
    }
}
