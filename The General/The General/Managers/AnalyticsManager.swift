//
//  AnalyticsManager.swift
//  The General
//
//  Created by Hopkinson, Todd (US - Denver) on 1/25/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    
    enum AnalyticEvent: String {
        case signIn = "Signin"
        case signInTouchID = "UniqueSigninwithTouchID"
        case signInGoogle = "UniqueSignInwithGoogle"
        case signInFacebook = "UniqueSignInwithFacebook"
        
        case idCardsLandscapeViewed = "QuickAccessToIDCards"
        case idCardsWasViewed = "IDCardsViews"
        case idCardsWasPrinted = "IDCardsPrinted"
        case idCardsWasViewedLoggedOut = "IDCardsLoggedOut"
        
        case aboutSectionWasVisited = "VisitedAboutsection-Unique"
        case appPreferencesWasVisited = "VisitedAppPreferences-Unique"
        case appPreferenceSetAllowIDCardAccessWhileLoggedOut = "Choosetoallowaccesstocard/infowhileNOTloggedin"
        
        case communicationPreferencesChangeWasInitiated = "CommunicationPreferencesChange-Initiated"
        case communicationPreferencesChangeDidComplete = "CommunicationPreferencesChange-Completed"
        
        case otherProductsMerchWasVisited = "VisitOtherproducts/merchandise"

        case paymentsPayNearMeInitiated = "PaymentType-PayNearMe-Initiated"
        case paymentsPayNearMeCompleted = "PaymentType-PayNearMe-Completed"
        case paymentsPayNearMeDeclined = "PaymentType-PayNearMe-Declined"

        case paymentsCCDebitInitiated = "PaymentType-CC/Debit-Initiated"
        case paymentsCCDebitDeclined = "PaymentType-CC/Debit-Declined"
        case paymentsCCDebitCompleted = "PaymentType-CC/Debit-Completed"
        
        case paymentsECheckInitiated = "PaymentType-eCheck-Initiated"
        case paymentsECheckDeclined = "PaymentType-eCheck-Declined"
        case paymentsECheckCompleted = "PaymentType-eCheck-Completed"
        
        case paymentsMultipleInitiated = "MuliplePayments-Initiated"
        case paymentsMultipleDeclined = "MuliplePayments-Declined"
        case paymentsMultipleCompleted = "MuliplePayments-Completed"
        
        // TODO: below...
        case paymentsTotalScreenWasVisited = "Payments-Total" // TODO:
        case paymentsTotalActionWasInitiated = "Payments-TotalInitiated" // TODO:
        case paymentsTotalActionWasDeclined = "Payments-TotalDeclined" // TODO:
        case paymentsTotalActionDidComplete = "Payments-TotalComplete" // TODO:

        case scheduledPaymentsInitiated = "ScheduledPayments-Initiated" // TODO:
        case scheduledPaymentsDeclined = "ScheduledPayments-Declined" // TODO:
        case scheduledPaymentsCompleted = "ScheduledPayments-Completed" // TODO:
        
        case paymentRenewalInitiated = "Renewal-Initiated" // TODO:
        case paymentRenewalCompleted = "Renewal-Completed" // TODO:
        
        case autopaySignup = "AutoPay-SignUp" // TODO:
        case autopayRemoved = "AutoPay-Removed" // TODO:
        case autpayStatusWasViewed = "AutoPayStatus" // TODO:
		
		case supportCallBackInitiated = "CallBack-Initiated" // TODO:
		case supportCallBackCompleted = "CallBack-Completed" // TODO:
		case supportContactUsVisitUse = "ContactUsVisit/Use" // TODO:
		
		case claimsFnolInitiated = "ClaimsFNOL-Initiated" // TODO:
		case claimsFnolSubmitted = "ClaimsFNOL-Submitted" // TODO:
		
		case notificationsPaymentRemindersInitiated = "PaymentReminders-Initiated" // TODO:
		case notificationsAccountAlertsReceived = "AccountAlerts-Received" // TODO:
		case notificationsPromoAreaView = "PromoArea-Views" // TODO:
		case notificationsPromoAreaClicks = "PromoArea-Clicks" // TODO:
		case notificationsBiometricLoginsTotals = "BiometricLogins-Totals" // TODO:
		case notificationsPushNotificationOptIn = "PushNotificationOptin" // TODO:
		case notificationsEmailOptIn = "EmailOptin" // TODO:
		case notificationsTextOptIn = "TextOptin" // TODO:
		case notificationsPushNotificationOptOut = "PushNotificationOptOut" // TODO:
		case notificationsEmailOptOut = "EmailOptOut" // TODO:
		case notificationsTextOptOut = "TextOptOut" // TODO:

        /* questionables as yet unsolved - awaiting direction/clarification on these:
         GEN-1207 (Sign In)
         -TotalSignIn
         -TotalSignInwithGoogle
         -TotalSignInwithFacebook
         -TotalSigninwithTouchID
         -UniqueTouchIDsetupcompleteForgotPassword // NOTE: this looks like two tags accidentally joined?
         -TotalForgotPassword-Unique
         -ActiveApps-last30,60,90days
         -AppCrashes
         -Associatinganactivitytoauser/policynumber
         
         GEN-1211 (Profile/Preferences/About)
         VisitedAboutsection-Total
         VisitedAppPreferences-Total
         
         GEN-1213 (Payments tracking)
		 Payments-Total
		 Payments-TotalInitiated
		 Payments-TotalDeclined
		 Payments-TotalComplete
		 Averagepaymentsmethodsperuser

         GEN-1215 (Quotes Tagging)
         QuotesRetrieved
         QuotesInitiated
         Refill-Initiated
         Refill-Completed
         SalesFromApp
         
         GEN-1217 (Account Management Tagging)
         MyPolicyRegistrations
         Endorsements-Initiated
         Visit/UseCoverage
         Visit/UseDrivers
         Visit/UseVehicles
         Visit/UseAgent
         
         GEN-1219 (Support Tracking)
         ChatTotals
         %ofChatsdeflected
         KB/HelpCenterTotalUsage
         KB/HelpCenterTopArticles
         CallsFromApp(Trackcallclicks)
         
         GEN-1221 (Claims Tracking)
         ClaimsFNOL-Funnel/Conversionforeachstep
         ClaimsStatus/Tracker-Viewed/Visited/Used
         ClaimsInfo-Viewed/Visited/Used
         KeyActivitiesinFNOL?i.e.Picturessubmitted
         
         GEN-1223 (Notifications tagging)
         PaymentReminders-Initiated
         AccountAlerts-Received
         BiometricLogins-Totals
         */
    }
    
    static func track(event: AnalyticEvent, parameters: [String: Any]? = nil) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
    
}
