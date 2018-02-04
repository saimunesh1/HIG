//
//  AutoPay.swift
//  The General
//
//  Created by Teman, Kevin (US - Denver) on 1/10/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

//--------------------------------------------------------------------------
// MARK: - Manager
//--------------------------------------------------------------------------

class AutoPayManager {
    
    
    //MARK: - View to Manager
    func viewHasLoaded() {
        
        self.view.showLoading()
        
        self.fetchInformation(information: { [weak self] (items) in
            
            self?.view.hideLoading()
            self?.view.showScheduleItems(items: items)
            
        }) {  [weak self] in
            
            self?.view.hideLoading()
            self?.view.showCouldNowLoadScheduleItems()
        }
    }
    
    
    //MARK: - Private
    unowned var view: AutoPayStatusViewController
    
    init(view: AutoPayStatusViewController) {
        self.view = view
    }
    
    fileprivate lazy var service = AutoPayService()
    
    /**
     Fetch information about current auto pay payments.
     - Parameters:
        - information: Receive items inside.
        - items: Auto pay status items.
        - failed: Called if service fails.
     */
    fileprivate func fetchInformation(information: @escaping (_ items: [AutoPayStatusViewController.Item]) -> (), failed: @escaping ()->()) {
        
        guard let policyNumber = SessionManager.policyNumber else {
            failed()
            return
        }
        
        self.service.fetchHistory(forPolicy: policyNumber) { [weak self] innerClosure in
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
    
    /**
     Sign in can be called with OR without username and password. If no username and password are passed in, then username and password will be taken from keychain (stored at last login).
     - Parameters:
        - items: Accept items created from Auto Pay Service.
     - Returns: Items which can be used in view controller.
     */
    fileprivate func getViewItems(fromServiceItems items: [AutoPayService.HistoryItem]) -> [AutoPayStatusViewController.Item] {
        
        var viewItems: [AutoPayStatusViewController.Item] = []
        
        for item in items {
            
            guard let issuedOnString = item.issuedOn, let dueOnString = item.dueOn, let issuedOnDate = DateFormatter.callbackTimezoneDateFormatter.date(from: issuedOnString), let dueOnDate = DateFormatter.callbackTimezoneDateFormatter.date(from: dueOnString), let amount = item.amount, let displayAmount = NumberFormatter.currency.string(from: amount.rawValue as NSDecimalNumber) else {
                continue
            }
            
            let monthDayYear = DateFormatter.monthDayYear
            
            let invoiceDateDisplay = monthDayYear.string(from: issuedOnDate)
            let draftOnDisplay = monthDayYear.string(from: dueOnDate)
            
            let viewItem = AutoPayStatusViewController.Item(date: invoiceDateDisplay, amount: displayAmount, draftOn: draftOnDisplay)
            
            viewItems.append(viewItem)
        }
        
        return viewItems
    }
}

//--------------------------------------------------------------------------
// MARK: - View Controller
//--------------------------------------------------------------------------

class AutoPayStatusViewController: UIViewController {
    
    
    //MARK: - Interface
    struct Item {
        let date: String
        let amount: String
        var draftOn: String
    }
    
    enum PaymentType {
        case card
        case bankAccount
    }
    
    // These must be set at launch
    //
    var autoPayMethodDisplay: String!
    
    
    //MARK: Header Information
    func showAutoPaySource(paymentSource: String) {
        
        self.statusLabel.attributedText = NSAttributedString(string: "Your next payment will be automatically applied using " + self.autoPayMethodDisplay)
    }
    
    
    //MARK: Schedule
    func showCouldNowLoadScheduleItems() {
        self.paymentScheduleTableView.reloadData()
    }
    
    func showScheduleItems(items: [AutoPayStatusViewController.Item]) {
        self.scheduleItems = !items.isEmpty ? items : nil
        self.paymentScheduleTableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.automatic)
    }
    
    func showLoading() {
        LoadingView.show(inView: self.paymentScheduleTableView, type: .hud, displayText: "Loading Schedule...", animated: true)
    }
    
    func hideLoading() {
        LoadingView.hide(inView: self.paymentScheduleTableView, animated: true)
    }
    
    @IBAction func cancelAutopayAction(_ sender: UIButton) {
        
        guard let rootViewController = self.view.window?.rootViewController, let cancelAutoPay = self.storyboard?.instantiateViewController(withIdentifier: "Cancel Auto Pay") as? AutoPayCancelViewController else {
            
            return
        }
        
        rootViewController.present(cancelAutoPay, animated: true, completion: nil)
    }
    
    
    //MARK: - Private
    override func viewDidLoad() {
        super.viewDidLoad()
        self.manager.viewHasLoaded()
    }
    
    @IBOutlet fileprivate weak var statusLabel: UILabel!
    fileprivate lazy var manager = AutoPayManager(view: self)
    fileprivate var scheduleItems: [Item]?
    @IBOutlet fileprivate weak var paymentScheduleTableView: UITableView!
}

extension AutoPayStatusViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let items = scheduleItems else {
            return 1
        }
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let items = scheduleItems, items.indices.contains(indexPath.row) else {
            return tableView.dequeueReusableCell(withIdentifier: "No Information")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Schedule") as! AutoPayHistoryCell
        let item = items[indexPath.row]
        cell.setup(withItem: item)
        
        return cell
    }
}

class AutoPayHistoryCell: UITableViewCell {
    
    
    //MARK: - Interface
    func setup(withItem item: AutoPayStatusViewController.Item) {
        
        self.item = item
        
        self.invoiceDateLabel.text = item.date
        self.amountLabel.text = item.amount
        self.draftOnLabel.text = item.draftOn
        
        self.layoutIfNeeded()
    }
    
    
    //MARK: - Private
    @IBOutlet weak var invoiceDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var draftOnLabel: UILabel!
    
    fileprivate var item: AutoPayStatusViewController.Item?
}
