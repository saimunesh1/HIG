//
//  MenuVC.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 11/23/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

enum MenuStateType {
    case policyHeld
    case policyPending
    case policyNone
}

enum MenuItemType {
    case home
    case payments
    case idCards
    case policy
    case claims
    case quotes
    case about
    case otherProducts
    case feedback
    case support
    
    var displayName: String {
        switch self {
        case .home: return NSLocalizedString("menu.home", comment: "Home")
        case .payments: return NSLocalizedString("menu.payments", comment: "Payments")
        case .idCards: return NSLocalizedString("menu.idcards", comment: "ID cards")
        case .policy: return NSLocalizedString("menu.policydetails", comment: "Policy details")
        case .claims: return NSLocalizedString("menu.claims", comment: "Claims")
        case .quotes: return NSLocalizedString("menu.quotes", comment: "Quotes")
        case .about: return NSLocalizedString("menu.about", comment: "About")
        case .otherProducts: return NSLocalizedString("menu.other", comment: "Other products/apps")
        case .feedback: return NSLocalizedString("menu.feedback", comment: "Feedback")
        case .support: return NSLocalizedString("menu.support", comment: "Support")
        }
    }
}

class MenuViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var preferencesIconImageView: UIImageView!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!

    var menuState: MenuStateType = .policyNone {
        didSet {
            setupMenuItems()
        }
    }
    
    var selectedMenuItem: MenuItemType?
    private var activeMenuItems: [MenuItemType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMenuItems()
        setupAppearance()
        setupSessionListener()
        updateMenuOptions()
    }

    @IBAction func didTouchPreferencesButton(_ sender: UIButton) {
        ApplicationContext.shared.navigator.replace("pgac://preferences", context: nil, wrap: BaseNavigationController.self)
        self.drawerController?.closeDrawer()
    }

    @IBAction func didTouchNameButton(_ sender: UIButton) {
        ApplicationContext.shared.navigator.replace("pgac://profile", context: nil, wrap: BaseNavigationController.self)
        self.drawerController?.closeDrawer()
    }

    @IBAction func didTouchSignOutButton(_ sender: UIButton) {
        SessionManager.endSession()
        ApplicationContext.shared.navigator.replace("pgac://login", context: nil, wrap: nil, handleDrawerController: false)
    }
}


// MARK: - Private
extension MenuViewController {
    fileprivate func setupAppearance() {
        preferencesIconImageView.tintColor = .white
        userIconImageView.tintColor = .white
    }
    
    fileprivate func setupSessionListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionStarted),
            name: SessionManager.Notifications.sessionStarted.name,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionEnded),
            name: SessionManager.Notifications.sessionEnded.name,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePreloadingFinished),
            name: PreloadingManager.Notifications.finished.name,
            object: nil)
    }
    
    fileprivate func setupMenuItems() {
        var menuItems: [MenuItemType] = []
        
        switch menuState {
        case .policyHeld:
            menuItems += [.home, .payments, .idCards, .policy, .claims]
        case .policyPending:
            menuItems += [.home, .idCards, .policy]
        case .policyNone:
            break
        }
        
        menuItems += [
            .quotes,
            .about,
            .otherProducts,
            .feedback,
            .support,
        ]
        
        self.activeMenuItems = menuItems
        self.selectedMenuItem = nil
        
        self.tableView.reloadData()
    }
    
    @objc fileprivate func sessionStarted() {
        updateMenuOptions()
    }
    
    @objc fileprivate func sessionEnded() {
        updateMenuOptions()
    }

    @objc fileprivate func handlePreloadingFinished() {
        updateMenuOptions()
    }
    
    fileprivate func updateMenuOptions() {
        let dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo

        if let _ = SessionManager.policyNumber {
            if dashboardInfo?.policyStatus == .entry {
                menuState = .policyPending
            } else {
                menuState = .policyHeld
            }
        } else {
            menuState = .policyNone
        }
        
        fullNameLabel.text = dashboardInfo?.insuredName ?? NSLocalizedString("menu.noname", comment: "")
    }
}


// MARK: - UITableViewDataSource
extension MenuViewController: UITableViewDataSource {
    
    enum CellIdentifier: String {
        case menuItem = "MenuItem"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activeMenuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.menuItem.rawValue, for: indexPath) as! MenuItemTableViewCell
        
        let menuItem = self.activeMenuItems[indexPath.row]
        cell.titleLabel.text = menuItem.displayName
        
        return cell
    }
}


// MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let menuItem = self.activeMenuItems[indexPath.row]
        
        switch menuItem {
		case .about:
			ApplicationContext.shared.navigator.replace("pgac://about", context: nil, wrap: BaseNavigationController.self)
			self.drawerController?.closeDrawer()

		case .claims:
            ApplicationContext.shared.navigator.replace("pgac://claims", context: nil, wrap: BaseNavigationController.self)
            self.drawerController?.closeDrawer()
            
        case .home:
            ApplicationContext.shared.navigator.replace("pgac://dashboard", context: nil, wrap: BaseNavigationController.self)
            self.drawerController?.closeDrawer()
            
        case .payments:
            ApplicationContext.shared.navigator.replace("pgac://payments", context: nil, wrap: BaseNavigationController.self)
            self.drawerController?.closeDrawer()
            
        case .quotes:
            ApplicationContext.shared.navigator.replace("pgac://quotes", context: nil, wrap: BaseNavigationController.self)
            self.drawerController?.closeDrawer()
            
        case .policy:
            ApplicationContext.shared.navigator.replace("pgac://policy", context: nil, wrap: BaseNavigationController.self)
            self.drawerController?.closeDrawer()

        case .idCards:
            ApplicationContext.shared.navigator.replace("pgac://idcards", context: nil, wrap: BaseNavigationController.self)
            self.drawerController?.closeDrawer()
            
        default:
            if let vc = ApplicationContext.shared.navigator.replace("pgac://support", context: nil, wrap: BaseNavigationController.self) {
                
                if menuItem == .otherProducts {
                    AnalyticsManager.track(event: .otherProductsMerchWasVisited) // this is questionable, as currently this item simply goes to the support screen, however, this is how this menu item is currently coded
                }
                
                // Only show the hamburger if the user is logged in
                if SessionManager.accessToken != nil {
                    // TODO: Only if we didn't come here from a help button
                    vc.baseNavigationController?.showMenuButton()
                }
            }
            
            self.drawerController?.closeDrawer()
        }
    }
}
