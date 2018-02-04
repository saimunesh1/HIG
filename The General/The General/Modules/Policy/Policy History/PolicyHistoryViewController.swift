//
//  PolicyHistoryViewController.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/5/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class PolicyHistoryViewController: BaseVC {
    
    enum CellIdentifier {
        case header(String)
        case renewal(PolicyHistoryResponse)
    }
    
    @IBOutlet weak var tableView: UITableView!

    private var histories: [CellIdentifier] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchPreviousPolicies()
    }
    
    private func configureUI() {
    }
    
    private func fetchPreviousPolicies() {
        LoadingView.show()
        
        ApplicationContext.shared.policyManager.getPolicyHistory(completion: { [weak self] (innerClosure) in
            LoadingView.hide()

            guard let `self` = self else { return }
            self.histories = []
            var previousYear: String?
            
            (try? innerClosure())?.forEach() { phr in
                if let yearNoticed = phr.yearNoticed, previousYear != phr.yearNoticed {
                    self.histories.append(.header(yearNoticed))
                }
                
                previousYear = phr.yearNoticed
                self.histories.append(.renewal(phr))
            }
            
            self.tableView.reloadData()
        })
    }
}

extension PolicyHistoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch histories[row] {
        case .header(let yearString):
            let cell = tableView.dequeueReusableCell(withIdentifier: "PolicyHistoryHeaderCell", for: indexPath) as! PolicyHistoryHeaderCell
            cell.year = yearString
            
            return cell
        case .renewal(let phr):
            let cell = tableView.dequeueReusableCell(withIdentifier: "PolicyHistoryRenewalCell", for: indexPath) as! PolicyHistoryRenewalCell
            cell.policyHistoryResponse = phr
            
            return cell
        }
    }
}
