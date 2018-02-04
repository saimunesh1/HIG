//
//  LoadingView.swift
//  The General
//
//  Created by Derek Bowen on 10/17/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

enum LoadingViewType {
    case fullscreen
    case hud
}

class LoadingView: UIView {
    
    static var presentedLoadingView: LoadingView?
    
    //MARK: Interface
    class func show(type: LoadingViewType = .hud, withDisplayText displayText: String? = nil, animated: Bool = true) {
        if let view = UIApplication.shared.keyWindow?.rootViewController?.view {
            self.show(inView: view, type: type, displayText: displayText, animated: animated)
        }
    }
    
    class func hide(animated: Bool = true, finishedHiding: (() -> ())? = nil) {
        if let view = UIApplication.shared.keyWindow?.rootViewController?.view {
            self.hide(inView: view, animated: animated, complete: finishedHiding)
        }
    }
    
    class func show(inView view: UIView, type: LoadingViewType, displayText: String? = nil, animated: Bool) {
        
        if presentedLoadingView == nil {
            presentedLoadingView = LoadingView()
        }

        guard let presentedLoadingView = presentedLoadingView else { return }
        
        view.addSubview(presentedLoadingView)
        presentedLoadingView.setupContraints(displayType: type, inRelationToSuperview: view)
        
        presentedLoadingView.setDisplayText(text: displayText)
        presentedLoadingView.layoutIfNeeded()
        presentedLoadingView.show(animated: animated, completion: nil)
    }
    
    class func showComplete(animated: Bool = true, inView containingView: UIView? = nil, finished: (() -> ())? = nil) {
        
        var view: UIView! = containingView
        
        if view == nil {
            view = UIApplication.shared.keyWindow?.rootViewController?.view
        }
        
        guard view != nil else {
            return
        }
        
        guard let loadingView = self.loadingView(inView: view) else {
            return
        }
        
        loadingView.showCompleteStatus(animated: animated) {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.hide(inView: view, animated: animated, complete: {
                    finished?()
                })
            }
        }
    }

    class func hide(inView view: UIView, animated: Bool, complete: (() -> ())? = nil) {
        guard let loadingView = self.loadingView(inView: view) else { return }
        
        loadingView.hide(animated: animated) {
            loadingView.removeFromSuperview()
            complete?()
        }
        
        presentedLoadingView = nil
    }
    
    
    //MARK: Private
    fileprivate func setDisplayText(text: String?) {
        
        guard let text = text, !text.isEmpty else {
            self.centerShell.spacing = 0
            return
        }
        
        self.displayLabel.text = text
        self.centerShell.spacing = 10
    }
    
    fileprivate lazy var centerShell: UIStackView = {
        let centerShell = UIStackView(arrangedSubviews: [self.activityIndicator, self.displayLabel])
        centerShell.alignment = UIStackViewAlignment.center
        centerShell.axis = .vertical
        centerShell.spacing = 0
        centerShell.distribution = .equalSpacing
        centerShell.translatesAutoresizingMaskIntoConstraints = false
        
        return centerShell
    }()
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        return activityIndicator
    }()
    
    fileprivate lazy var displayLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    fileprivate lazy var completionImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "24px__check"))
        imageView.tintColor = UIColor.tgGreen
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
    }
}


// MARK: - Private
extension LoadingView {
    fileprivate func setupView() {
        self.showDarkBackground()
        self.alpha = 0
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.centerShell)
        
        self.addConstraint(NSLayoutConstraint(item: self.centerShell, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: self.centerShell, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint(item: self.centerShell, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 0.85, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: self.centerShell, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 0.70, constant: 0.0))
    }
    
    fileprivate func showDarkBackground() {
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
    }
    
    fileprivate func showLightBackground() {
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
    }
    
    fileprivate class func loadingView(inView view: UIView) -> LoadingView? {
        for view in view.subviews.reversed() {
            if let loadingView = view as? LoadingView {
                return loadingView
            }
        }
        
        return nil
    }
    
    fileprivate func show(animated: Bool, completion: (() -> Void)?) {
        guard self.alpha != 1.0 else { return }
        
        self.alpha = 0.0
        let duration = (animated) ? 0.25 : 0.0
        
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.alpha = 1.0
        }, completion: { (success) in
            completion?()
        })
    }
    
    fileprivate func hide(animated: Bool, completion: (() -> Void)?) {
        guard self.alpha != 0.0 else { return }
        
        self.alpha = 1.0
        let duration = (animated) ? 0.25 : 0.0
        
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.alpha = 0.0
        }, completion: { (success) in
            completion?()
        })
    }
    
    fileprivate func showCompleteStatus(animated: Bool = true, finished: (() -> ())? = nil) {
        
        func switchContent() {
            
            for view in self.centerShell.arrangedSubviews {
                view.removeFromSuperview()
            }
            
            self.showLightBackground()
            
            self.centerShell.addArrangedSubview(self.completionImageView)
            
            self.centerShell.layoutIfNeeded()
        }
        
        guard animated else {
            switchContent()
            return
        }
        
        func animate(thisStuff: @escaping() -> (), animationFinished: (()->())? = nil) {
            
            switchContent()
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
                self.layoutIfNeeded()
                
            }, completion: { (animationComplete) in
                animationFinished?()
            })
        }
        
        animate(thisStuff: {
            switchContent()
            
        }, animationFinished: {
            finished?()
        })
    }
    
    fileprivate func setupContraints(displayType: LoadingViewType = .hud, inRelationToSuperview superview: UIView) {
        
        let views = [
            "loadingView": self
        ]
        
        switch displayType {
            
        case .fullscreen:
            superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[loadingView]|", options: [], metrics: nil, views: views))
            superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[loadingView]|", options: [], metrics: nil, views: views))
            
        case .hud:
            self.layer.cornerRadius = 10.0
            
            let kDesiredSize: CGFloat = 88.0

            
            // Center in superview
            superview.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            superview.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            
            // Always greater or equal to desired size
            superview.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: kDesiredSize))
            superview.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .width, multiplier: 1.0, constant: kDesiredSize))
            
            // Always less than most of the screen vertically and horizontally
            superview.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .lessThanOrEqual, toItem: superview, attribute: .height, multiplier: 0.9, constant: 0))
            superview.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .lessThanOrEqual, toItem: superview, attribute: .width, multiplier: 0.9, constant: 0))
            
            // Desired height and width
            let desiredHeight = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: kDesiredSize)
            desiredHeight.priority = UILayoutPriority(rawValue: 1)
            superview.addConstraint(desiredHeight)
            
            let desiredWidth = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: kDesiredSize)
            desiredWidth.priority = UILayoutPriority(rawValue: 1)
            superview.addConstraint(desiredWidth)
        }
    }
}
