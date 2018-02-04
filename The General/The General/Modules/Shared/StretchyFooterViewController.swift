//
//  StretchyFooterViewController.swift
//  The General
//
//  Created by Lee Irvine on 11/21/17.
//  Copyright © 2017 The General. All rights reserved.
//

// USAGE:
//
// Built to support UITableViewController in storyboard
// Place two static cells in the tableView, and the bottom cell
// will stretch to fill the screen.
//
// Connect the non-stretchable header cell to outlet below
// Supports only 2 cells, a stretchy cell, and a header cell.

import UIKit

class StretchyFooterViewController: UITableViewController {
    @IBOutlet var stretchyFooterCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let lastIndex = self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1
        
        if(indexPath.row == lastIndex) {

            return self.footerHeight(section: indexPath.section);
        } else {
            
            let fixedHeight = super.tableView(tableView, heightForRowAt: indexPath)
            return fixedHeight

        }
        
    }
    
    private func footerHeight(section: Int) -> CGFloat {
        let viewHeight = self.tableView.frame.size.height

        let lastIndex = tableView(tableView, numberOfRowsInSection: section) - 2
        var headerHeight: CGFloat = 0
        
        if lastIndex > 0 {
            for index:Int in 0...lastIndex {

                let tbview = self.tableView!
                let indexPath = IndexPath(item: index, section: section)
                
                headerHeight += self.tableView(tbview, heightForRowAt: indexPath)
            }
        }
        
        return CGFloat(
                viewHeight -
                headerHeight -
                self.tableView.separatorInset.left -
                self.tableView.separatorInset.right);
    }
    
}
