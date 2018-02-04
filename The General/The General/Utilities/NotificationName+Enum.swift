//
//  NotificationName+Enum.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

protocol NotificationName {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: NotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}
