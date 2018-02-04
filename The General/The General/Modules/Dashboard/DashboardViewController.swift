//
//  DashboardVC.swift
//  The General
//
//  Created by Bowen, Derek (US - Denver) on 11/22/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import AirshipKit
import SafariServices

class DashboardViewController: UITableViewController, QuoteNavigatable, ClaimNavigatable, OverlayNavigatable {
    
    enum UserDefaultKeys: String {
        case hasDisplayedHelpCenter = "hasDisplayedHelpCenter"
    }
    
    enum Segues: String {
        case showHelpCenterOverlay = "showHelpCenterOverlay"
    }
    
    enum CellIdentifier: String {
        case policyInfo = "PolicyInfoCell"
        case policyPayment = "PolicyPaymentCell"
        case policyRenew = "PolicyRenewCell"
        case policyPendingInfo = "PolicyPendingInfoCell"
        case driversOnPolicy = "DriversOnPolicyCell"
        case noClaimsYet = "NoClaimsYetCell"
        case outstandingClaims = "OutstandingClaimsCell"
        case getQuote = "GetQuoteCell"
        case previousQuotes = "PreviousQuotesCell"
        case promo = "PromoCell"
        case didYouKnowLandscape = "DidYouKnowLandscapeCell"
        case didYouKnowFingerprint = "BiometryCell"

        static func allObjectStrings() -> [String] {
            return [
                self.policyInfo.rawValue,
                self.policyPayment.rawValue,
                self.policyRenew.rawValue,
                self.policyPendingInfo.rawValue,
                self.driversOnPolicy.rawValue,
                self.noClaimsYet.rawValue,
                self.outstandingClaims.rawValue,
                self.getQuote.rawValue,
                self.previousQuotes.rawValue,
                self.promo.rawValue,
                self.didYouKnowLandscape.rawValue,
                self.didYouKnowFingerprint.rawValue
            ]
        }
    }
    
    private var cells: [CellIdentifier] = []

    // when we find out the height of claims, we store that value here
    private var outstandingClaimsTableHeight: CGFloat?

    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCells()
        setupInitialState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestNotificationPermissions()
    }
    
    fileprivate func setupInitialState() {
        updateCells()
        self.setupPreloading()
        self.baseNavigationController?.showMenuButton()
    }
    
    fileprivate func setupCells() {
        CellIdentifier.allObjectStrings().forEach() {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
    }
    
    fileprivate func updateCells() {
        self.outstandingClaimsTableHeight = nil
        
        if let dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo {
            if !dashboardInfo.hasPolicy {
                cells = [.getQuote]
                
                if let quotes = dashboardInfo.quotes, !quotes.isEmpty {
                    cells += [.previousQuotes]
                }
            } else {
                if dashboardInfo.isExpiredPolicy {
                    cells = [.policyInfo, .policyRenew, .getQuote, .driversOnPolicy, .noClaimsYet]
                } else if dashboardInfo.isPendingPolicy {
                    cells = [.policyPendingInfo]
                } else {
                    cells = [.policyInfo, .policyPayment, .driversOnPolicy]
                }

                if let claims = dashboardInfo.claims, !claims.isEmpty {
                    cells += [.outstandingClaims]
                } else if !dashboardInfo.isExpiredPolicy, !dashboardInfo.isPendingPolicy {
                    cells += [.noClaimsYet]
                }
                
                if !biometricEnabled && ApplicationContext.shared.biometricManager.typeAvailable != BiometricType.none {
                    cells += [.didYouKnowFingerprint]
                }

                cells += [.didYouKnowLandscape]
            }

            // promo shouldn't display if roadside assistance is included in the policy
            if !(ApplicationContext.shared.dashboardManager.dashboardInfo?.hasRoadsideAssistanceFlag ?? false) {
                cells += [.promo]
            }
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ClaimsDetailVC, let claim = sender as? Claim {
            vc.claim = claim
        }
    }
    
    @IBAction func didPressIDCard(_ sender: Any) {
        if SessionManager.isSessionValid || IDCardManager.isCardIDInfoCached {
            let vc = UIStoryboard(name: "IDCards", bundle: nil).instantiateViewController(withIdentifier: "IDCardsVC") as! IDCardsVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


// MARK: Biometry
extension DashboardViewController {
    var biometricEnabled: Bool {
        get {
            return SettingsManager.biometryEnabled
        } set {
            SettingsManager.biometryEnabled = newValue
        }
    }
}

// MARK: - Table View
extension DashboardViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cellIdentifier = cells[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue, for: indexPath)
        
        switch cellIdentifier {
        case .didYouKnowFingerprint:
            guard let bioCell = cell as? BiometryCell else { break }
            bioCell.delegate = self
        case .policyInfo:
            guard let piCell = cell as? PolicyInfoCell else { break }
            piCell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
        case .policyPayment:
            guard let ppCell = cell as? PolicyPaymentCell else { break }
            ppCell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
        case .policyRenew:
            guard let prCell = cell as? PolicyRenewCell else { break }
            prCell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
        case .policyPendingInfo:
            guard let ppiCell = cell as? PolicyPendingInfoCell else { break }
            ppiCell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
        case .getQuote:
            guard let gqCell = cell as? GetQuoteCell else { break }
            
            gqCell.bordered = ApplicationContext.shared.dashboardManager.dashboardInfo?.hasPolicy ?? false
            
            gqCell.onDidTouchGetAQuote = { [weak self] in
                self?.showGetAQuoteActionSheet(zipCode: nil)
            }
            
            gqCell.onDidTouchPhoneByQuote = { [weak self] in
                self?.showGetAQuoteByPhoneActionSheet()
            }
        case .previousQuotes:
            guard let pqCell = cell as? PreviousQuotesCell else { break }

            pqCell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo            
            pqCell.onContinueApplication = { [weak self] quote in
                self?.continueApplication(quote: quote)
            }
            
            pqCell.onSeePreviousQuotes = { [weak self] in
                self?.showExistingQuotes()
            }
        case .driversOnPolicy:
            guard let dopCell = cell as? DriversOnPolicyCell else { break }
            dopCell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo
        case .noClaimsYet:
            guard let ncyCell = cell as? NoClaimsYetCell else { break }
            
            ncyCell.onCreateClaimButtonTouched = {
                ApplicationContext.shared.navigator.present("pgac://fnol/start", context: nil, from: nil, animated: true, completion: nil)
            }
        case .outstandingClaims:
            guard let ocCell = cell as? OutstandingClaimsCell else { break }
            ocCell.dashboardInfo = ApplicationContext.shared.dashboardManager.dashboardInfo

            ocCell.onHeightCalculated = { [weak self] height in
                guard let `self` = self else { return }

                if self.outstandingClaimsTableHeight == nil || self.outstandingClaimsTableHeight != height {
                    self.outstandingClaimsTableHeight = height
                    self.tableView.reloadData()
                }
            }

            ocCell.onCreateClaimButtonTouched = {
                ApplicationContext.shared.navigator.present("pgac://fnol/start", context: nil, from: nil, animated: true, completion: nil)
            }
            
            ocCell.onNavigateToClaimDetails = { [weak self] claim in
                self?.performSegue(withIdentifier: "showClaimsDetailVC", sender: claim)
            }

            ocCell.onNavigateToResumeClaim = { [weak self] claimId in
                ApplicationContext.shared.navigator.present("pgac://fnol/resume/\(claimId)", context: nil, wrap: nil, from: self, animated: true, completion: nil)
            }

            ocCell.onNavigateToEmailEnrollment = { [weak self] in
                self?.performSegue(withIdentifier: "showClaimsEmailEnrollmentVC", sender: nil)
            }
            
            ocCell.onAskToSubmitClaim = { [weak self] claim in
                self?.askToSubmitClaim(claim: claim)
            }
        case .promo:
            guard let promoCell = cell as? PromoCell else { break }
            promoCell.promo = DashboardManager.promo
            
            
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // until we know the exact content height of claims, make it something excessive
        if cells[indexPath.row] == .outstandingClaims {
            return outstandingClaimsTableHeight ?? 50000.0
        }
        
        return UITableViewAutomaticDimension
    }
}


extension DashboardViewController: BiometryCellDelegate {
    func biometryWasEnabled() {
        self.updateDashboard()
    }
}


// MARK: - Private
extension DashboardViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            controller.dismiss(animated: true, completion: {
                // TODO: Show alert
            })
        }
    }
}

extension DashboardViewController {
    
    fileprivate func requestNotificationPermissions() {
        if !SettingsManager.didRequestPushNotificationPermission {
            SettingsManager.didRequestPushNotificationPermission = true
            UAirship.push()?.userPushNotificationsEnabled = true
            UAirship.push().defaultPresentationOptions = [.alert, .badge, .sound]
        }
    }
    
    fileprivate func updateDashboard() {
        updateCells()
    }
}


// MARK: - Preloading
extension DashboardViewController {
    
    fileprivate func setupPreloading() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionChanged),
            name: SessionManager.Notifications.sessionStarted.name,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionChanged),
            name: SessionManager.Notifications.sessionEnded.name,
            object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handlePreloadingFinished), name: PreloadingManager.Notifications.finished.name, object: nil)
        
        if ApplicationContext.shared.preloadingManager.isLoading {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                LoadingView.show(inView: rootViewController.view, type: .fullscreen, animated: false)
            }
        } else {
            // tutorial overlay
            showAccessCardOverlayIfNecessary()
        }
    }
    
    @objc fileprivate func sessionChanged() {
        updateDashboard()
    }

    @objc func handlePreloadingFinished() {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            LoadingView.hide(inView: rootViewController.view, animated: true)
            updateDashboard()
        }

        // tutorial overlay
        showAccessCardOverlayIfNecessary()
    }
}
