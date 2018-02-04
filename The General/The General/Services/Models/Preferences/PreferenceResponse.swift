//
//  PreferenceResponce.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 13/01/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

struct PreferencesResponse: Decodable {
    var appPreferences: [Notifications]?
    var pushNotifications: [Notifications]?
    var email: [Notifications]?
}

struct Notifications: Decodable {
    var name: String
    var enabled: Bool
}
