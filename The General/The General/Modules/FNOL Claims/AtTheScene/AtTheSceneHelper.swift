//
//  AtTheSceneHelper.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 12/1/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class AtTheSceneHelper {
    class func atTheSceneActionSheet(forQuestionnaire questionnaire: Questionnaire) -> UIAlertController? {
        guard let page = questionnaire.getPageForId(id: "at_scene") else {
            return nil
        }
        
        guard let pageId = page.pageId,
            let sections = questionnaire.getSectionList(pageID: pageId),
            let currentSection = sections.first,
            let values = currentSection.fieldsArray?.first?.validValuesArray,
            let message = currentSection.fieldsArray?.first?.label else {
            return nil
        }
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.view.layer.cornerRadius = 10.0
        
        let messageFont = [NSAttributedStringKey.font: UIFont.alert]
        let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont)
        actionSheet.setValue(messageAttrString, forKey: "attributedMessage")
        actionSheet.addAction(UIAlertAction(title: values[0].value, style: .default) { _ in
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(values[0].code!, displayValue: nil, forResponseKey: "claim.atScene")
            ApplicationContext.shared.navigator.push("pgac://fnol/onboarding", context: nil, from: nil, animated: true)
        })
        
        actionSheet.addAction(UIAlertAction(title: values[1].value, style: .default) { _ in
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(values[1].code!, displayValue: nil, forResponseKey: "claim.atScene")
            ApplicationContext.shared.navigator.push("pgac://fnol/onboarding", context: nil, from: nil, animated: true)
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction)in
//            actionSheet.removeFromParentViewController()
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheet.addAction(cancelAction)
        
        actionSheet.changeTitleFont(fontStyle: UIFont.alert)
        
        return actionSheet
    }
}
