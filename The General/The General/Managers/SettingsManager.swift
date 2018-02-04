//
//  SettingsManager.swift
//  The General
//
//  Created by Derek Bowen on 10/6/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

enum Environment {
    case internalDevelopment
    case development
    case mock
    case production
}

class SettingsManager {
	
    static var environment: Environment {
        #if ENV_INTERNAL_DEVELOPMENT
            return .internalDevelopment
        #elseif ENV_DEVELOPMENT
            return .development
        #elseif ENV_MOCK
            return .mock
        #else
            return .production
        #endif
    }
	
	static var didRequestPushNotificationPermission: Bool {
		set(newValue) {
			UserDefaults.standard.set(newValue, forKey: "didRequestPushNotificationPermission")
		}
		get {
			return UserDefaults.standard.bool(forKey: "didRequestPushNotificationPermission")
		}
	}
	
	static var hasAgreedToTermsAndConditions: Bool {
		set(newValue) {
			UserDefaults.standard.set(newValue, forKey: "hasAgreedToTermsAndConditions")
		}
		get {
			return UserDefaults.standard.bool(forKey: "hasAgreedToTermsAndConditions")
		}
	}
    
	static var hasLoggedInAtLeastOnce: Bool {
		set(newValue) {
			UserDefaults.standard.set(newValue, forKey: "hasLoggedInAtLeastOnce")
		}
		get {
			return UserDefaults.standard.bool(forKey: "hasLoggedInAtLeastOnce")
		}
	}
	
    static var rememberUsername: Bool {
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "rememberUsername")
        }
        get {
            return UserDefaults.standard.bool(forKey: "rememberUsername")
        }
    }
	
	static var firstLaunchCompleted: Bool {
		get {
			return UserDefaults.standard.bool(forKey: "firstLaunchCompleted")
		}
		set(newValue) {
			UserDefaults.standard.set(newValue, forKey: "firstLaunchCompleted")
		}
	}
    
    static var biometryEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "biometryEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "biometryEnabled")
        }
    }
	
	static var refillUrl: String? {
		get {
			return UserDefaults.standard.string(forKey: "refillUrl")
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "refillUrl")
		}
	}
    
    // Preferences
    static var textMessageEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "textMessageEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "textMessageEnabled")
        }
    }
    
    static var automatedCallEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "automatedCallEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "automatedCallEnabled")
        }
    }
}
