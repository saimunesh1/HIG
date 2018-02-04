//
//  SupplementalNavigationController.swift
//  The General
//
//  Created by Derek Bowen on 10/26/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

protocol SupplementalNavigationControllerProtocol {
    /// Determines if the view controller wants supplemental views to appear.
    ///
    /// - Returns: If we should show supplements
    func shouldDisplayNavigationBarSupplements() -> Bool
}

extension UIViewController {
    var supplementalNavigationController: SupplementalNavigationController? {
        return self.navigationController as? SupplementalNavigationController
    }
}

class SupplementalNavigationController: UINavigationController {
    fileprivate var supplementalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.distribution = .equalSpacing
        stackView.clipsToBounds = true
        
        return stackView
    }()
    
    fileprivate var extendedNavigationBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.tgGray
        
        view.addSubview(separatorView)
        separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 7)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        
        return view
    }()
    
    fileprivate var heightOfNavBarPlusExtendedViewIfDisplayed: CGFloat {
        let navigationBarHeight = self.navigationBar.frame.maxY
        let extendedViewHeight = (self.extendedNavigationBarView.isHidden) ? 0 : self.extendedNavigationBarView.bounds.height
        
        return navigationBarHeight + extendedViewHeight
    }
    
    /// Supplemental views
    var supplementalViews: [UIView] {
        return self.supplementalStackView.arrangedSubviews
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.setupView()
    }
    
    var overallHeightConstraint: NSLayoutConstraint!
    var lastTimeViewShown: Date!
}


// MARK: - Adding/removing supplemental views
extension SupplementalNavigationController {
    /// Adds a supplemental view below the navigation bar.
    ///
    /// - Parameters:
    ///   - view: View to add
    ///   - index: Index to add the view at
    ///   - animated: Should animate presentation
    func addSupplementalView(_ view: UIView, atIndex index: Int = Int.max, animated: Bool) {
        
        guard !self.supplementalStackView.arrangedSubviews.contains(view) else {
            return
        }
        
        if let lastTime = lastTimeViewShown, Date().timeIntervalSince(lastTime) < 0.5 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.addSupplementalView(view, atIndex: index, animated: animated)
            }
            return
        }
        
        lastTimeViewShown = Date()
        
        var insertIndex = index
        if index < 0 {
            insertIndex = 0
        }
        else if index > self.supplementalStackView.arrangedSubviews.count {
            insertIndex = self.supplementalStackView.arrangedSubviews.count
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        
        self.supplementalStackView.insertArrangedSubview(view, at: insertIndex)
        
        // Constraints
        view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        let heightConstraint = view.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        
        self.supplementalStackView.layoutIfNeeded()
		
		let newViewHeight = view.intrinsicContentSize.height
		
		heightConstraint.constant = newViewHeight
		self.overallHeightConstraint.constant += newViewHeight

        // Adjust size of content view
        if let viewController = self.visibleViewController, !self.extendedNavigationBarView.isHidden {

			if let topConstraint = viewController.topConstraint {
				topConstraint.constant = self.extendedNavigationBarView.frame.size.height + newViewHeight
			}
        }
		
        let duration = (animated) ? 0.3 : 0.0
        UIView.animate(withDuration: duration, delay: 0, options: .beginFromCurrentState, animations: {
            
			self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    /// Removes all supplimental views instantly without animation.
    ///
    func removeAllSupplimentalViewsInstantly() {
        for view in self.supplementalStackView.arrangedSubviews {
            self.removeSupplementalView(view, animated: false)
        }
    }
    
    /// Removes a supplemental view at the specified index.
    ///
    /// - Parameters:
    ///   - index: Index of view to remove
    ///   - animated: Should animate removal
    func removeSupplementalView(atIndex index: Int, animated: Bool) {
        guard case 0..<self.supplementalStackView.arrangedSubviews.count = index else { return }
        
        let supplementalView = self.supplementalStackView.arrangedSubviews[index]
        self.removeSupplementalView(supplementalView, animated: animated)
    }
    
    /// Removes a supplemental view.
    ///
    /// - Parameters:
    ///   - view: View to remove
    ///   - animated: Should animate removal
    func removeSupplementalView(_ view: UIView, animated: Bool) {
        guard self.supplementalStackView.arrangedSubviews.contains(view) else { return }
        
        view.removeConstraints(view.constraintsAffectingLayout(for: .vertical))
        view.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
        let viewHeight = view.intrinsicContentSize.height
        
        self.overallHeightConstraint.constant -= viewHeight
        
        // Adjust size of content view
        if let viewController = self.visibleViewController, !self.extendedNavigationBarView.isHidden {

            if let topConstraint = viewController.topConstraint {
                topConstraint.constant = max(topConstraint.constant - viewHeight, 0)
            }
        }
		
        let duration = (animated) ? 0.5 : 0.0
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
            view.isHidden = true
            
        }) { _ in
            view.removeFromSuperview()
            view.isHidden = false
        }
    }
}


// MARK: - Momentary supplemental views
extension SupplementalNavigationController {
    /// Adds a supplemental view that disappears after a short duration.
    ///
    /// - Parameters:
    ///   - view: View to add
    ///   - index: Index to add the view at
    ///   - animated: Should animate presentation/removal
    func addMomentarySupplementaryView(_ view: UIView, atIndex index: Int = Int.max, animated: Bool) {
        self.addSupplementaryView(view, removeDelay: 3, atIndex: index, animated: animated)
    }
    
    func addLongerSupplementaryView(_ view: UIView, atIndex index: Int = Int.max, animated: Bool) {
        self.addSupplementaryView(view, removeDelay: 7, atIndex: index, animated: animated)
    }
    
    func addSupplementaryView(_ view: UIView, removeDelay: Double, atIndex index: Int = Int.max, animated: Bool) {
        guard !self.supplementalStackView.arrangedSubviews.contains(view) else { return }
        
        self.addSupplementalView(view, atIndex: index, animated: animated)
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + removeDelay) {
            self.removeSupplementalView(view, animated: true)
        }
    }
}


// MARK: - Private
extension SupplementalNavigationController {
    fileprivate func setupView() {
        self.view.backgroundColor = .white
        self.navigationBar.isTranslucent = false
        self.navigationBar.shadowImage = #imageLiteral(resourceName: "navbarBackground")
        self.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "navbarBackground"), for: .default)
        
        self.view.addSubview(self.extendedNavigationBarView)
        
        // - Extended navigation bar view
        self.extendedNavigationBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.extendedNavigationBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.extendedNavigationBarView.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor).isActive = true
        
        self.navigationBar.superview?.bringSubview(toFront: self.navigationBar)
        
        // Add separator to navigation bar
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.tgGray
        self.navigationBar.addSubview(separatorView)
        separatorView.leadingAnchor.constraint(equalTo: self.navigationBar.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: self.navigationBar.trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: self.navigationBar.bottomAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        self.setupSupplementalStackView()
    }
    
    fileprivate func setupSupplementalStackView() {
        self.extendedNavigationBarView.addSubview(self.supplementalStackView)
        
        // - Constraints
        self.supplementalStackView.leadingAnchor.constraint(equalTo: self.extendedNavigationBarView.leadingAnchor).isActive = true
        self.supplementalStackView.trailingAnchor.constraint(equalTo: self.extendedNavigationBarView.trailingAnchor).isActive = true
        self.supplementalStackView.topAnchor.constraint(equalTo: self.extendedNavigationBarView.topAnchor).isActive = true
        self.supplementalStackView.bottomAnchor.constraint(equalTo: self.extendedNavigationBarView.bottomAnchor, constant: -1.0).isActive = true
        
        self.overallHeightConstraint = self.supplementalStackView.heightAnchor.constraint(equalToConstant: 0)
        self.overallHeightConstraint.isActive = true
    }
}

extension SupplementalNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let vcProtol = viewController as? SupplementalNavigationControllerProtocol {
            self.extendedNavigationBarView.isHidden = !vcProtol.shouldDisplayNavigationBarSupplements()
        }
        else {
            self.extendedNavigationBarView.isHidden = false
        }
        
        let topHeight = self.heightOfNavBarPlusExtendedViewIfDisplayed
        viewController.view.frame = CGRect(x: 0, y: topHeight, width: self.view.bounds.width, height: self.view.bounds.height - topHeight)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let topHeight = self.heightOfNavBarPlusExtendedViewIfDisplayed
        viewController.view.frame = CGRect(x: 0, y: topHeight, width: self.view.bounds.width, height: self.view.bounds.height - topHeight)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push, .pop:
            return CustomPushPopTransitioner(operation: operation)
        case .none:
            break
        }
        return nil
    }
}


/// We need to replace the transitioner so we can control the starting frame.
class CustomPushPopTransitioner: NSObject, UIViewControllerAnimatedTransitioning {
    var operation: UINavigationControllerOperation
    
    init(operation: UINavigationControllerOperation) {
        self.operation = operation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView: UIView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!.view
        let toView: UIView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view
        
        // Ensure we don't get unwanted artifacts
        fromView.clipsToBounds = true
        toView.clipsToBounds = true
        
        let container = transitionContext.containerView
        container.addSubview(toView)
        container.bringSubview(toFront: fromView)
        
        var toFrame = toView.frame
        toFrame.origin.x = (self.operation == .push) ? fromView.bounds.width : -fromView.bounds.width
        toView.frame = toFrame
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                                   animations: {
                                    var fromFrame = fromView.frame
                                    fromFrame.origin.x = (self.operation == .push) ? -fromView.bounds.width : fromView.bounds.width
                                    fromView.frame = fromFrame
                                    
                                    toFrame.origin.x = 0
                                    toView.frame = toFrame
        }) { (complete) -> Void in
            transitionContext.completeTransition(true)
        }
    }
}
