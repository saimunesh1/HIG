//
//  PromoCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 12/15/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit
import Nuke

class PromoCell: UITableViewCell {
    @IBOutlet var promoImageView: UIImageView!
    @IBOutlet var dashboardBoxView: DashboardBoxView!
    
    var promo: GetFeaturedPromoResponse? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateView()
    }
    
    private func updateView() {
        if let imageUrl = promo?.imageUrl, let url = URL(string: imageUrl) {
            Nuke.Manager.shared.loadImage(with: url, completion: { [weak self] image in
                self?.promoImageView.image = image.value
            })
        } else {
            promoImageView.image = nil
        }
        
        dashboardBoxView.isHidden = (promoImageView.image == nil)
    }
}
