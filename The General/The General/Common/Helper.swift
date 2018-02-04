//
//  Helper.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 9/19/17.
//  Copyright © 2017 Deloitte Digital. All rights reserved.
//

import UIKit

struct ScreenSize {
    static let screenWidth      = UIScreen.main.bounds.size.width
    static let screenHeight     = UIScreen.main.bounds.size.height
    static let screenMaxLength  = max(ScreenSize.screenWidth, ScreenSize.screenHeight)
    static let screenMinLength  = min(ScreenSize.screenWidth, ScreenSize.screenHeight)
}

struct DeviceType {
    static let isIPhone         = UIDevice.current.userInterfaceIdiom == .phone
    static let isIPhone4OrLess  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength < 568.0
    static let isIPhone5        = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength == 568.0
    static let isIPhone6        = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength == 667.0
    static let isIPhone6P       = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLength == 736.0
    static let isIPhone7        = isIPhone6
    static let isIPhone7P       = isIPhone6P
}


class Helper: NSObject {
    
    class func getDataFromJSON(jsonFileName: String) -> Data? {
        guard let filepath = Bundle.main.path(forResource: jsonFileName, ofType: "json") else { return nil }
        guard let data = NSData(contentsOfFile: filepath) as Data? else { return nil }
        return data
    }
    
    class func readJson() -> AnyObject? {
        do {
            if let file = Bundle.main.url(forResource: "FNOLClaims", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let objectDictioanary = json as? [String: Any] {
                    // json is a dictionary
                    print(objectDictioanary)
                    
                    return objectDictioanary as NSDictionary
                } else if let objectArray = json as? [Any] {
                    // json is an array
                    print(objectArray)
                    
                    return objectArray as NSArray
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
            
            return nil
        }
        
        return nil
    }
    
    class func isScalingRequired() -> Bool {
        return DeviceType.isIPhone5 || DeviceType.isIPhone4OrLess
    }
    
    class func requiredAttributedText(text: String) -> NSMutableAttributedString {
        let dynamictext  = text + " *"
        let attributedString = NSMutableAttributedString(string: dynamictext)
        attributedString.setColorForText("*", with: .tgGreen)
        return attributedString
    }
    
}
