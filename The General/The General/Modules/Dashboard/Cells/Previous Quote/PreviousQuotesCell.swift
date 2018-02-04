//
//  PreviousQuotesCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PreviousQuotesCell: UITableViewCell {
    enum CellIdentifier: String {
        case previousQuote = "PreviousQuoteCell"
        
        static var allObjectStrings: [String] {
            return [
                self.previousQuote.rawValue,
            ]
        }
    }
    
    var onContinueApplication: ((QuoteResponse) -> ())?
    var onSeePreviousQuotes: (() -> ())?
    
    var dashboardInfo: DashboardResponse? {
        didSet {
            tableView.reloadData()

            if let dashboardInfo = dashboardInfo, let quotes = dashboardInfo.quotes {
                tableViewHeightConstraint.constant = quotes.reduce(0.0, { $0 + PreviousQuoteCell.heightForCell(quote: $1) })
            }
        }
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        CellIdentifier.allObjectStrings.forEach() {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
            tableView.tableFooterView = UIView()
        }
    }
}

extension PreviousQuotesCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dashboardInfo = dashboardInfo,
            let quotes = dashboardInfo.quotes
            else { return 0 }

        return quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let quotes = dashboardInfo?.quotes else { return UITableViewCell() }
        let quote = quotes[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.previousQuote.rawValue, for: indexPath) as! PreviousQuoteCell

        cell.quote = quote
        cell.onContinueApplication = { [weak self] quote in
            self?.onContinueApplication?(quote)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let quotes = dashboardInfo?.quotes else { return 0.0 }
        let quote = quotes[indexPath.row]

        return PreviousQuoteCell.heightForCell(quote: quote)
    }
}

extension PreviousQuotesCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSeePreviousQuotes?()
    }
}
