//
//  UITableViewCell+Custom.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/21/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    func addSeparator(y: CGFloat, margin: CGFloat, color: UIColor) {
        let sepFrame = CGRect(x: margin, y: y, width: self.frame.width - (margin * 2), height: 0.7);
        let seperatorView = UIView(frame: sepFrame);
        seperatorView.backgroundColor = color;
        seperatorView.autoresizingMask = .flexibleWidth
        self.addSubview(seperatorView);
    }
    
    public func addTopSeparator(tableView: UITableView) {
        self.addSeparator(y: 0, margin: 15, color: tableView.separatorColor!);
    }
    
    public func addBottomSeparator(tableView: UITableView, cellHeight: CGFloat) {
        self.addSeparator(y: cellHeight-1, margin: 15, color: tableView.separatorColor!);
    }
    
    public func removeSeparator(width: CGFloat) {
        self.separatorInset = UIEdgeInsetsMake(0.0, width, 0.0, 0.0);
    }
}
