//
//  AppDelegate.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 9/19/17.
//  Copyright © 2017 Deloitte Digital. All rights reserved.
//

import UIKit
import CoreData
import MagicalRecord
import HockeySDK
import FBSDKLoginKit
import GoogleSignIn
import AirshipKit
import FirebaseAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	enum QuickAction: String {
		case seeIdCard = "com.pgac.thegeneralinsurance.quickactions.see.id.card"
		case makePayment = "com.pgac.thegeneralinsurance.quickactions.make.payment"
		case startClaimsProcess = "com.pgac.thegeneralinsurance.quickactions.start.claims.process"
		case getQuote = "com.pgac.thegeneralinsurance.quickactions.get.quote"
	}
	
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Initalize hockey app
        self.setupHockeyApp()
        self.setupUrbanAirship()
        self.setupFirebase()
        self.setupGoogleSignIn()
        
        // Initialize the persistence manager
        _ = PersistenceManager.shared
        
        // Register route handlers for the various modules
        self.registerRoutes()
        
        // Update configuration
        self.getConfiguration()
        
        // Setup device/screen orientation
        self.setupOrientation()

		// Branch based on whether this is the first launch of the app or not
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        self.window?.makeKeyAndVisible()
		setInitialView()
		
		return true
    }
	
	private func setInitialView() {
		if SettingsManager.firstLaunchCompleted {
			if SessionManager.isSessionValid {
				// Start preloading process...
				ApplicationContext.shared.preloadingManager.startPreloadingData()
				
				ApplicationContext.shared.navigator.replace("pgac://dashboard", context: nil, wrap: nil, handleDrawerController: false)
			}
			else {
				ApplicationContext.shared.navigator.replace("pgac://login", context: nil, wrap: nil, handleDrawerController: false)
			}
		}
		else {
			ApplicationContext.shared.navigator.replace("pgac://onboarding", context: nil, wrap: nil, handleDrawerController: false)
		}
	}

	func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        PersistenceManager.shared.saveToPersistentStore()
        SessionManager.refreshSession()
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
	
	func application(_ application: UIApplication, didChangeStatusBarFrame oldStatusBarFrame: CGRect) {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "statusBarFrameChanged"), object: nil)
	}

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
         NetworkReachability.isConnectedToNetwork() ? print("Online") : print("Offline")
		if !SessionManager.isSessionValid {
			let visibleVC = UIApplication.shared.visibleViewController
			if visibleVC is GetAQuoteVC || visibleVC is SignInViewController || visibleVC is PreSignInViewController {
				// Do nothing -- the user may be in the middle of getting a quote
			} else {
				ApplicationContext.shared.navigator.replace("pgac://login", context: nil, wrap: nil, handleDrawerController: false)
			}
		}
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        MagicalRecord.cleanUp()
        SessionManager.refreshSession()
    }

    
// MARK: OAUTH - FACEBOOK & GOOGLE
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        // Facebook login handles the URL
        if FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                  open: url,
                                                                  sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                  annotation: options[UIApplicationOpenURLOptionsKey.annotation]) {
            return true
        }
        
        // Google login handles the URL
        if GIDSignIn.sharedInstance().handle(url,
                                             sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                             annotation: options[UIApplicationOpenURLOptionsKey.annotation] as? String) {
            return true
        }
        
        return false;
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }

}

// MARK: - Routing
extension AppDelegate {
    fileprivate func registerRoutes() {
		SignInRoutes.registerRoutes()
		ClaimsRoutes.registerRoutes()
        FNOLRoutes.registerRoutes()
        PaymentsRoutes.registerRoutes()
		QuotesRoutes.registerRoutes()
        DashboardRoutes.registerRoutes()
        PolicyRoutes.registerRoutes()
        PreferencesRoutes.registerRoutes()
        ProfileRoutes.registerRoutes()
		SupportRoutes.registerRoutes()
        IDCardsRoutes.registerRoutes()
    }
}


// MARK: - Configuration
extension AppDelegate {
    fileprivate func getConfiguration() {
        ApplicationContext.shared.configurationManager.getConfiguration { (innerClosure) in
        }
    }
}


// MARK: - Orientation
extension AppDelegate {
    
    func setupOrientation() {
        _ = OrientationManager()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return OrientationManager.shared.orientationLock
    }
}


// MARK: - Urban Airship
extension AppDelegate {
    fileprivate func setupUrbanAirship() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUAChannelCreated(notification: )), name: NSNotification.Name(rawValue: UAChannelCreatedEvent), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUAChannelUpdated(notification: )), name: NSNotification.Name(rawValue: UAChannelUpdatedEvent), object: nil)
        
        UAirship.takeOff()
    }
    
    @objc func handleUAChannelCreated(notification: NSNotification) {
        debugPrint("Channel Created: \(notification)")
    }
    
    @objc func handleUAChannelUpdated(notification: NSNotification) {
        debugPrint("Channel Updated: \(notification)")
    }
}


// MARK: - HockeyApp
extension AppDelegate {
    fileprivate func setupHockeyApp() {
        #if DEBUG
        BITHockeyManager.shared().configure(withIdentifier: "9c6d3a1540994b31ad4a341841ebdbdb")
        BITHockeyManager.shared().isUpdateManagerDisabled = true
        BITHockeyManager.shared().start()
        #endif
    }
}


// MARK: - Google Services
extension AppDelegate {
    fileprivate func setupGoogleSignIn() {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
            GIDSignIn.sharedInstance().clientID = plist["CLIENT_ID"] as! String
            GIDSignIn.sharedInstance().delegate = GoogleSignInDelegate.sharedDelegate
        } else {
            print("error: Google sign configuration missing")
        }
    }
    
    fileprivate func setupFirebase() {
        FirebaseApp.configure()
    }
}

// MARK: - Home screen quick actions
extension AppDelegate {
	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		// Handle quick actions
		completionHandler(handleQuickAction(shortcutItem: shortcutItem))
	}
	
	func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
		var quickActionHandled = false
		let type = shortcutItem.type
		if let shortcutType = QuickAction.init(rawValue: type) {
			switch shortcutType {
			case .seeIdCard:
				ApplicationContext.shared.navigator.replace("pgac://idcards", context: nil, wrap: BaseNavigationController.self)
				quickActionHandled = true
			case .makePayment:
				ApplicationContext.shared.navigator.replace("pgac://payments", context: nil, wrap: BaseNavigationController.self)
				quickActionHandled = true
			case .startClaimsProcess:
				ApplicationContext.shared.navigator.replace("pgac://claims", context: nil, wrap: BaseNavigationController.self)
				// Give the base view a while to load
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
					ApplicationContext.shared.navigator.present("pgac://fnol/start", context: nil, wrap: nil)
				})
				quickActionHandled = true
			case .getQuote:
				ApplicationContext.shared.navigator.replace("pgac://quotes/getaquote", context: nil, wrap: BaseNavigationController.self)
				quickActionHandled = true
			}
		}
		return quickActionHandled
	}
	
}

extension UIApplication {
	
	var visibleViewController: UIViewController? {
		guard let rootViewController = keyWindow?.rootViewController else { return nil }
		return getVisibleViewController(rootViewController)
	}
	
	private func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {
		if let presentedViewController = rootViewController.presentedViewController {
			return getVisibleViewController(presentedViewController)
		}
		if let navigationController = rootViewController as? UINavigationController {
			return navigationController.visibleViewController
		}
		if let tabBarController = rootViewController as? UITabBarController {
			return tabBarController.selectedViewController
		}
		return rootViewController
	}

}
