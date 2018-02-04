//
//  DashboardBoxView.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

@IBDesignable
class DashboardBoxView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLineView: UIView!

    @IBInspectable
    var title: String = "" {
        didSet {
            updateUI()
        }
    }

    private var titleShouldDisplay: Bool {
        return !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }


    // MARK: - View
    private func setupUI() {
        // border & shadow
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.tgGray.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: -4, height: 4)

        // title
        let titleLabel = UILabel()
        addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "OpenSans-SemiBold", size: 16.0)
        titleLabel.textColor = .tgGreen
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4.0).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        self.titleLabel = titleLabel
        
        // title line
        let titleLineView = UIView()
        addSubview(titleLineView)

        titleLineView.translatesAutoresizingMaskIntoConstraints = false
        titleLineView.backgroundColor = .tgGray
        titleLineView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        titleLineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.0).isActive = true
        titleLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        titleLineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        self.titleLineView = titleLineView

        updateUI()
    }
    
    private func updateUI() {
        titleLabel.text = title
        titleLabel.isHidden = !titleShouldDisplay
        titleLineView.isHidden = !titleShouldDisplay
    }
}
