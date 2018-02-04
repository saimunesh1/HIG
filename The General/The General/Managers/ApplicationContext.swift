//
//  ApplicationContext.swift
//  The General
//
//  Created by Derek Bowen on 10/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

class ApplicationContext {
	
    static let shared = ApplicationContext()
    
    /// URL Routing for view controllers
    let navigator = Navigator()
    
    /// Preloading
    let preloadingManager = PreloadingManager()
    
    /// Feature Module Managers
	lazy var biometricManager = BiometricManager()
	lazy var claimsManager = ClaimsManager()
	lazy var configurationManager = ConfigurationManager()
	lazy var dashboardManager = DashboardManager()
	lazy var documentsManager = DocumentsManager()
	lazy var fnolClaimsManager = FNOLClaimsManager()
    lazy var idCardManager = IDCardManager()
	lazy var locationManager = LocationManager()
	lazy var paymentsManager = PaymentsManager()
	lazy var phoneCallManager = PhoneCallManager()
	lazy var preferencesManager = PreferencesManager()
	lazy var quotesManager = QuotesManager()
	lazy var signInManager = SignInManager()
    lazy var policyManager = PolicyManager()
	lazy var supportManager = SupportManager()
    lazy var profileManager = ProfileManager()
    lazy var phoneOptionsManager = PhoneOptionsManager()
}
