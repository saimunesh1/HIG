//
//  PaymentHistoryViewController.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 1/8/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation
import UIKit

//--------------------------------------------------------------------------
// MARK: - Manager
//--------------------------------------------------------------------------
///
/// Discussion: Handles interaction between the service and view controller
///
class PaymentHistory {
    
    //Since Payment History is activated from storyboard segue, this manager is created from within the view controller
    init(view: PaymentHistoryViewController) {
        self.view = view
    }
    
    
    //MARK: - View to Manager
    func viewHasLoaded() {
        
        self.view.showLoading()
        
        self.fetchInformation(information: { [weak self] viewItems in
            
            self?.view.hideLoading()
            self?.view.showPaymentItems(viewItems)
            
        }) { [weak self] in
            
            self?.view.hideLoading()
            self?.view.showCouldNotLoad()
        }
    }
    
    
    //MARK: - Private
    fileprivate lazy var service = PaymentHistoryService()
    fileprivate unowned var view: PaymentHistoryViewController
    
    fileprivate func fetchInformation(information: @escaping (_ items: [PaymentHistoryViewController.ViewItem]) -> (), failed: @escaping ()->()) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            failed()
            return
        }
        
        self.service.fetch(forPolicy: policyNumber) { [weak self] innerClosure in
            guard let strongSelf = self else {
                return
            }
            
            do {
                let items = try innerClosure()
                let viewItems = strongSelf.getViewItems(fromServiceItems: items)
                information(viewItems)
                
            } catch {
                failed()
            }
        }
    }
    
    fileprivate func getViewItems(fromServiceItems items: [PaymentHistoryService.Item]) -> [PaymentHistoryViewController.ViewItem] {
        
        var viewItems: [PaymentHistoryViewController.ViewItem] = []
        
        for item in items {
            
            guard let dateString = item.date, let amount = item.amount, let type = item.type, let trackerId = item.referenceId, let displayAmount = NumberFormatter.currency.string(from: amount.rawValue as NSDecimalNumber), let date = DateFormatter.callbackTimezoneDateFormatter.date(from: dateString) else {
                continue
            }
            
            let monthDayYear = DateFormatter.monthDayYear
            let hoursCivilian = DateFormatter.hoursCivilian
            
            let dateDisplay = monthDayYear.string(from: date)
            let timeDisplay = hoursCivilian.string(from: date) + " CDT"
            
            let viewItem = PaymentHistoryViewController.ViewItem(date: dateDisplay, time: timeDisplay, totalAmount: displayAmount, paymentType: type, trackerId: String(trackerId) )
            
            viewItems.append(viewItem)
        }
        
        return viewItems
    }
}


//--------------------------------------------------------------------------
// MARK: - View Controller
//--------------------------------------------------------------------------

class PaymentHistoryViewController: UITableViewController {
    
    
    //MARK: - Interface
    struct ViewItem {
        let date: String
        let time: String
        let totalAmount: String
        let paymentType: String
        let trackerId: String
    }
    
    
    //MARK: - Manager to View
    func showCouldNotLoad() {
        self.tableView.reloadData()
    }
    
    func showPaymentItems(_ items: [ViewItem]) {
        self.items = !items.isEmpty ? items : nil
        self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.automatic)
    }
    
    func showLoading() {
        LoadingView.show(inView: self.view, type: .hud, displayText: "Loading History...", animated: true)
    }
    
    func hideLoading() {
        LoadingView.hide(inView: self.view, animated: true)
    }
    
    
    //MARK: - Private
    fileprivate let kNoInformationCellHeight: CGFloat = 50
    fileprivate var items: [ViewItem]?
    fileprivate lazy var manager = PaymentHistory(view: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.manager.viewHasLoaded()
		tableView.tableFooterView = UIView() // Hides separators between empty rows
    }
    
    
    //MARK: - Actions
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Table Delegates
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let items = items, items.indices.contains(indexPath.row) else {
            return kNoInformationCellHeight
        }
        
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Payment History") as! PaymentHistoryCell
        
        cell.setup(withPaymentHistoryItem: item)
        
        return cell.desiredHeight
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let items = items else {
            return 1
        }
        
        return items.count
    }
    
    
    //MARK: - Table Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let items = items, items.indices.contains(indexPath.row) else {
            return tableView.dequeueReusableCell(withIdentifier: "No Information")!
        }
        
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Payment History") as! PaymentHistoryCell
        
        cell.setup(withPaymentHistoryItem: item)
        
        return cell
    }
}


//--------------------------------------------------------------------------
// MARK: - Cell
//--------------------------------------------------------------------------

class PaymentHistoryCell: UITableViewCell {
    
    
    //MARK: Interface
    func setup(withPaymentHistoryItem item: PaymentHistoryViewController.ViewItem) {
        
        self.item = item
        
        self.dateLabel.text = item.date
        self.timeLabel.text = item.time
        self.totalAmountLabel.text = item.totalAmount
        self.paymentTypeLabel.text = item.paymentType
        self.trackerIdLabel.text = item.trackerId
        
        self.layoutIfNeeded()
    }
    
    var desiredHeight: CGFloat {
        get {
            guard hasBeenSetup else {
                return 0
            }
            
            return self.trackerIdLabel.frame.maxY + kBottomBorder
        }
    }
    
    
    //MARK: Private
    fileprivate let kBottomBorder: CGFloat = 20
    
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    @IBOutlet fileprivate weak var totalAmountLabel: UILabel!
    @IBOutlet fileprivate weak var paymentTypeLabel: UILabel!
    @IBOutlet fileprivate weak var trackerIdLabel: UILabel!
    
    fileprivate var item: PaymentHistoryViewController.ViewItem?
    fileprivate var hasBeenSetup: Bool {
        get {
            return item != nil
        }
    }
}


//--------------------------------------------------------------------------
// MARK: - Service
//--------------------------------------------------------------------------

class PaymentHistoryService {
    
    typealias ResponseClosure = (() throws -> [Item]) -> ()
    
    func fetch(forPolicy policyNumber: String, completion: @escaping ResponseClosure) {
        
        let request = self.serviceManager.request(type: .get, path: "/rest/payment/paymentHistory/\(policyNumber)", headers: nil, body: nil)
        
        self.serviceManager.async(request: request) { (innerClosure) in
            do {
                let response = try innerClosure()
                
                guard let json = response.jsonObject else {
                        completion({ throw JSONErrorType.parsingError })
                        return
                }
                
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
                
                let responseModel = try JSONDecoder.shared.decode(Response.self, from: jsonData)
                
                guard let items = responseModel.data?.paymentHistoryItems else {
                    completion({ throw JSONErrorType.parsingError })
                    return
                }
                
                completion({ return items })
                
            } catch {
                completion({ throw error })
            }
        }
    }
    
    
    //MARK: - Private
    fileprivate let serviceManager = ServiceManager.shared
    
    struct Response: Decodable {
        var data: Data?
    }
    
    struct Data: Decodable {
        var paymentHistoryItems: [Item]
    }
    
    struct Item: Decodable {
        
        let date: String?
        let referenceId: String?
        let amount: CoercingDecimal?
        let type: String?
        let last4Digits: String?
        let label: String?
        let preferred: Bool?
    }
}
