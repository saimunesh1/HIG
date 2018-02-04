//
//  SupportWebViewCell.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 1/2/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit
import WebKit

class SupportWebViewCell: BaseTableViewCell {
	
	private let urlBase = "https://thegeneralauto.egain.cloud/system/templates/selfservice/thegeneral/help/customer/locale/en-US/portal/307700000001001/content/"
	private var webViewHeight: CGFloat = 300.0
	private var webView: WKWebView!
	
	public func setUp() {
		if (webView == nil) {
			webView = WKWebView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.width, height: webViewHeight))
			contentView.addSubview(webView)
			var allConstraints = [NSLayoutConstraint]()
			let views = ["webView": webView!]
			let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView(\(webViewHeight))]|", options: [], metrics: nil, views: views)
			let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: [], metrics: nil, views: views)
			allConstraints += verticalConstraints + horizontalConstraints
			NSLayoutConstraint.activate(allConstraints)
		}
	}
	
	public func open(articleId: String) {
		if let url = URL(string: "\(urlBase)\(articleId)") {
			webView.load(URLRequest(url: url))
		}
	}

}
