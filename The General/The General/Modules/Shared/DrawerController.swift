//
//  DrawerController.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 11/23/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

extension UIViewController {
    var drawerController: DrawerController? {
        return UIApplication.shared.keyWindow?.rootViewController as? DrawerController
    }
}

class DrawerController: UIViewController {
    /// Width of the drawer
    @IBInspectable
    var drawerWidth: CGFloat = 0.9
    
    /// Name of segue to embed main content
    @IBInspectable
    var mainSegueIdentifier: String?
    
    /// Name of segue to embed drawer content
    @IBInspectable
    var sideSegueIdentifier: String?
    
    /// Area on left-side of main content view to allow dragging in
    fileprivate static let dragAreaWidth: CGFloat = 40
    
    /// Current percentage the drawer is open, used for gestures
    fileprivate var drawerOpenPercentage: CGFloat = 0
    
    /// Is the drawer currently animating
    fileprivate var isAnimating: Bool = false
    
    /// Indicates if the drawer is open or not
    fileprivate(set) var drawerOpen: Bool = false
    
    /// Size of the drawer based on the current view size
    fileprivate var actualDrawerWidth: CGFloat {
        if self.drawerWidth <= 1.0 {
            return self.view.bounds.width * self.drawerWidth
        }
        else {
            return self.drawerWidth
        }
    }
    
    /// Containts to move the content views
    fileprivate var mainLeadingConstraint: NSLayoutConstraint?
    fileprivate var sideTrailingConstraint: NSLayoutConstraint?
    
    /// Main view controller
    fileprivate var _mainViewController: UIViewController?
    var mainViewController: UIViewController? {
        set {
            let oldLeadingConstant = self.mainLeadingConstraint?.constant ?? 0
            
            if let oldVC = self._mainViewController, oldVC != newValue {
                oldVC.view.removeFromSuperview()
            }
            
            self._mainViewController = newValue
            
            if let newVC = self._mainViewController {
                newVC.view.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(newVC.view)
                
                
                newVC.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                newVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                self.mainLeadingConstraint = newVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
                self.mainLeadingConstraint?.constant = oldLeadingConstant
                self.mainLeadingConstraint!.isActive = true
                newVC.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            }
        }
        get {
            return self._mainViewController
        }
    }
    
    
    /// Side drawer content view controller
    fileprivate var _sideViewController: UIViewController?
    var sideViewController: UIViewController? {
        set {
            let oldTrailingConstant = self.sideTrailingConstraint?.constant ?? 0
            
            if let oldVC = self._sideViewController, oldVC != newValue {
                oldVC.view.removeFromSuperview()
            }
            
            self._sideViewController = newValue
            
            if let newVC = self._sideViewController {
                newVC.view.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(newVC.view)
                
                newVC.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                newVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                self.sideTrailingConstraint = newVC.view.trailingAnchor.constraint(equalTo: self.view.leadingAnchor)
                self.sideTrailingConstraint?.constant = oldTrailingConstant
                self.sideTrailingConstraint!.isActive = true
                
                if self.drawerWidth <= 1.0 {
                    newVC.view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: self.drawerWidth).isActive = true
                }
                else {
                    newVC.view.widthAnchor.constraint(equalToConstant: self.drawerWidth).isActive = true
                }
            }
        }
        get {
            return self._sideViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_: )))
        tapGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_: )))
        panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        // Attempt to embed storyboard content
        if let mainSegueIdentifier = self.mainSegueIdentifier {
            self.performSegue(withIdentifier: mainSegueIdentifier, sender: self)
        }
        if let sideSegueIdentifier = self.sideSegueIdentifier {
            self.performSegue(withIdentifier: sideSegueIdentifier, sender: self)
        }
    }
}


// MARK: - Actions
extension DrawerController {
    /// Open the drawer
    func openDrawer() {
        guard !self.isAnimating else { return }
        
        self.mainViewController?.view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.mainLeadingConstraint?.constant = weakSelf.actualDrawerWidth
            weakSelf.sideTrailingConstraint?.constant = weakSelf.actualDrawerWidth
            weakSelf.view.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.isAnimating = false
                self?.drawerOpen = true
        })
    }
    
    /// Close the drawer
    func closeDrawer() {
        guard !self.isAnimating else { return }
        
        self.isAnimating = true
        self.mainViewController?.view.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.15, animations: { [weak self] in
            self?.mainLeadingConstraint?.constant = 0
            self?.sideTrailingConstraint?.constant = 0
            self?.view.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.isAnimating = false
                self?.drawerOpen = false
        })
    }
}


// MARK: - Gesture Recognizers
extension DrawerController: UIGestureRecognizerDelegate {
    /// Handles tap-gesture to open/close the drawer
    ///
    /// - Parameter gestureRecognizer: Tap gesture recognizer
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        guard !self.isAnimating else { return }
        guard self.drawerOpen else { return }
        
        if gestureRecognizer.state == .ended {
            let location = gestureRecognizer.location(in: self.view)
            
            if self._mainViewController?.view.frame.contains(location) == true {
                self.closeDrawer()
            }
        }
    }
    
    /// Handles pan-gestures for dragging the drawer open/closed
    ///
    /// - Parameter gestureRecognizer: Pan gesture recognizer
    @objc func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.location(in: self.view)
        
        switch gestureRecognizer.state {
        case .began:
            self.drawerOpenPercentage = (self.drawerOpen) ? 1 : 0
            
        case .changed:
            // Calculate the percentage, within [0, 1]
            var newOpenPercentage: CGFloat = 1 - ((self.actualDrawerWidth - location.x) / self.actualDrawerWidth)
            newOpenPercentage = CGFloat.minimum(1, newOpenPercentage)
            newOpenPercentage = CGFloat.maximum(0, newOpenPercentage)
            self.drawerOpenPercentage = newOpenPercentage
            
            // Open drawer to new percentage
            self.mainLeadingConstraint?.constant = self.actualDrawerWidth * self.drawerOpenPercentage
            self.sideTrailingConstraint?.constant = self.actualDrawerWidth * self.drawerOpenPercentage
            self.view.layoutIfNeeded()
            
        default:
            if self.drawerOpen {
                if self.drawerOpenPercentage <= 0.5 {
                    self.closeDrawer()
                }
                else {
                    self.openDrawer()
                }
            }
            else {
                if self.drawerOpenPercentage >= 0.5 {
                    self.openDrawer()
                }
                else {
                    self.closeDrawer()
                }
            }
        }
    }
    
    /// Check if the pan-gesture should be allowed
    ///
    /// - Parameter gestureRecognizer: Pan gesture recognizer
    /// - Returns: Should the gesture begin
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard !self.isAnimating else { return false }
        
        guard let mainVC = self._mainViewController else {
            return false
        }
        
        let location = gestureRecognizer.location(in: self.view)
        
        if gestureRecognizer is UIPanGestureRecognizer {
            if self.drawerOpen {
                // Can start dragging anywhere on the visible main view controller
                return mainVC.view.frame.contains(location)
            }
            else {
                // Can start dragging anywhere on the left of the main view controller, within the drag area width
                let dragRect = CGRect(
                    x: mainVC.view.frame.origin.x,
                    y: mainVC.view.frame.origin.y,
                    width: DrawerController.dragAreaWidth,
                    height: mainVC.view.frame.size.height
                )
                
                return dragRect.contains(location)
            }
        }
        if gestureRecognizer is UITapGestureRecognizer {
            if self.drawerOpen {
                return mainVC.view.frame.contains(location)
            }
        }
        
        return false
    }
}

/// Embed segue that captures the main content view controller
class DrawerEmbedMainControllerSegue: UIStoryboardSegue {
    override func perform() {
        if let source = self.source as? DrawerController {
            source.mainViewController = self.destination
        }
        else {
            assertionFailure("Soure view controller must be of type DrawerController")
        }
    }
}

/// Drawer segue that captures the side drawer content view controller
class DrawerEmbedSideControllerSegue: UIStoryboardSegue {
    override func perform() {
        if let source = self.source as? DrawerController {
            source.sideViewController = self.destination
        }
        else {
            assertionFailure("Soure view controller must be of type DrawerController")
        }
    }
}
