//
//  CustomPageControl.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/9/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class CustomPageControl: UIPageControl {
    
    let activeImage: UIImage = UIImage(named: "onboarding-circlesl_selected")!
    let inactiveImage: UIImage = UIImage(named: "onboarding-circles_unselected")!
    
    override var numberOfPages: Int {
        didSet {
            DispatchQueue.main.async{ [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.updateDots()
            }
        }
    }
    
    override var currentPage: Int {
        didSet {
            DispatchQueue.main.async{ [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.updateDots()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
        self.clipsToBounds = true
    }
    
    
    /// Update PageControl 
    ///
    func updateDots() {
        var i = 0
        for view in self.subviews {
            if let imageView = self.imageForSubview(view) {
                if i == self.currentPage {
                    imageView.image = self.activeImage
                } else {
                    imageView.image = self.inactiveImage
                }
                i = i + 1
            } else {
                var dotImage = self.inactiveImage
                if i == self.currentPage {
                    dotImage = self.activeImage
                }
                view.clipsToBounds = false
                view.addSubview(UIImageView(image: dotImage))
                i = i + 1
            }
        }
    }
    
    fileprivate func imageForSubview(_ view: UIView) -> UIImageView? {
        var dot: UIImageView?
        
        if let dotImageView = view as? UIImageView {
            dot = dotImageView
        } else {
            for foundView in view.subviews {
                if let imageView = foundView as? UIImageView {
                    dot = imageView
                    break
                }
            }
        }
        
        return dot
    }
    
    func setPage(page: Int) {
        super.currentPage = page
        self.updateDots()
    }
}
