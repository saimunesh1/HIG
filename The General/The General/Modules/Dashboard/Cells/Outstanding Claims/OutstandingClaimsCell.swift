//
//  OutstandingClaimsCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class OutstandingClaimsCell: UITableViewCell {
    enum CellIdentifier: String {
        case claimsClaimCell = "ClaimsClaimCell"
        case newClaimCell = "NewClaimCell"

        static func allObjectStrings() -> [String] {
            return [
                self.claimsClaimCell.rawValue,
                self.newClaimCell.rawValue
            ]
        }
    }
    
    var dashboardInfo: DashboardResponse? {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!

    var onNavigateToEmailEnrollment: (() -> ())?
    var onNavigateToClaimDetails: ((Claim) -> ())?
    var onNavigateToResumeClaim: ((String) -> ())?
    var onAskToSubmitClaim: ((FNOLClaim) -> ())?
    var onCreateClaimButtonTouched: (() -> ())?
    var onHeightCalculated: ((CGFloat) -> ())?
}

extension OutstandingClaimsCell: UITableViewDataSource {
    override func awakeFromNib() {
        CellIdentifier.allObjectStrings().forEach() {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dashboardInfo = dashboardInfo,
            let claims = dashboardInfo.claims
            else { return 1 }
        
        return claims.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let claims = dashboardInfo?.claims else { return UITableViewCell() }
        let row = indexPath.row

        if row < claims.count {
            let claim = claims[indexPath.row]
            
            var model = ClaimCellModel()
            model.populateFrom(claimEntry: claim)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.claimsClaimCell.rawValue, for: indexPath) as! ClaimsClaimCell

            cell.claimCellModel = model
            cell.isShadowed = false
            cell.delegate = self
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.newClaimCell.rawValue, for: indexPath) as! NewClaimCell
            
            cell.onDidTouchNewClaimButton = {
                self.onCreateClaimButtonTouched?()
            }
            
            cell.onRenderFinished = { [weak self] in
                guard let `self` = self else { return true }
                
                if let lastCell = tableView.visibleCells.first(where: { $0 is NewClaimCell }) {
                    let topMargin = self.tableViewTopConstraint.constant
                    let bottomMargin = self.tableViewBottomConstraint.constant
                    let height = lastCell.frame.origin.y + lastCell.frame.size.height + topMargin + bottomMargin
                    
                    self.onHeightCalculated?(height)
                    
                    return true
                }
                
                return false
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension OutstandingClaimsCell: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        guard let claims = dashboardInfo?.claims,
            row < claims.count,
            let claimCell = tableView.cellForRow(at: indexPath) as? ClaimsClaimCell,
            let claimCellModel = claimCell.claimCellModel
            else { return }
        
        if let claimId = claimCellModel.claimNumber, !claimId.isEmpty {
            // Get claim from getClaimInformation service
            LoadingView.show()
            ApplicationContext.shared.claimsManager.getClaim(claimId: claimId, completion: { [weak self] (innerClosure) in
                guard let `self` = self else { return }
                
                LoadingView.hide()
                do {
                    let responseModel = try innerClosure()
                    var claim = Claim(claimResponse: responseModel)
                    claim.claimStatus = claimCellModel.claimStatus
                    self.onNavigateToClaimDetails?(claim)
                } catch {
                    // TODO: Better error handling
                    print("Error retrieving list of claims: \(error)")
                }
            })
        } else if let fnolClaim = claimCellModel.fnolClaim { // No claim number; this claim has not yet been submitted
            let claim = Claim(fnolClaim: fnolClaim)
            onNavigateToClaimDetails?(claim)
        }
    }
}
extension OutstandingClaimsCell: ClaimsClaimCellDelegate {

    func didTapActionLink(cell: ClaimsClaimCell) {
        guard let claimCellModel = cell.claimCellModel else { return }
        
        switch claimCellModel.claimStatus! {
        case .claimSubmitted:
            onNavigateToEmailEnrollment?()
        case .draftSaved:
            if let localId = claimCellModel.fnolClaim?.localId {
                onNavigateToResumeClaim?(localId)
            }
        case .claimSaved:
            if let fnolClaim = claimCellModel.fnolClaim {
                onAskToSubmitClaim?(fnolClaim)
            }
        default:
            break
        }
    }
}
