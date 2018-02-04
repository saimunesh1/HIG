//
//  CoverageCustomControl.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/3/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class CoverageCustomControl: CustomSegmentControl {
    
    var value: CoverageConfig {
        get {
            return CoverageConfig(rawValue: self.selectedIndex)!
        }
        set {
            self.selectedIndex = newValue.rawValue
        }
    }
    
    override var items: [String] {
        get {
            let coverage = NSLocalizedString("policydetails.app.cover", comment: "")
            let drivers = NSLocalizedString("policydetails.app.drivers", comment: "")
            let vehicles = NSLocalizedString("policydetails.app.vehicles", comment: "")
            let agents = NSLocalizedString("policydetails.app.agents", comment: "")
            return [coverage, drivers, vehicles, agents]
        }
        set {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedIndex = CoverageConfig.coverage.rawValue
    }
    
}

enum CoverageConfig: Int {
    case coverage
    case drivers
    case vehicles
    case agents
}
