//
//  ClaimsProcessVC.swift
//  The General
//
//  Created by Alyn, Trevor (US - Denver) on 12/14/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

public enum ClaimNumberOfSteps {
	case six
	case nine
}

class ClaimsProcessVC: BaseVC {
	
	struct ClaimsProcessModel {
		let title: String
		let body: String
	}
	
	@IBOutlet weak var tableView: UITableView!
	
	public var numberOfSteps: ClaimNumberOfSteps = .six { didSet { setUpModel() } }

	private var stepsToShow = [Int]()
	private var claimsProcessModels = [ClaimsProcessModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpModel()
		tableView.dataSource = self
		tableView.delegate = self
    }

	private func setUpModel() {
		switch numberOfSteps {
		case .six:
			for index in 0..<6 {
				stepsToShow = [0, 1, 2, 3, 4, 5]
				claimsProcessModels.append(ClaimsProcessModel(title: NSLocalizedString("claimsprocess.titles.6.\(index + 1)", comment: ""), body: NSLocalizedString("claimsprocess.bodies.6.\(index + 1)", comment: "")))
			}
		case .nine:
			for index in 0..<9 {
				stepsToShow = [0, 1, 2, 3, 4, 5, 6, 7, 8]
				claimsProcessModels.append(ClaimsProcessModel(title: NSLocalizedString("claimsprocess.titles.9.\(index + 1)", comment: ""), body: NSLocalizedString("claimsprocess.bodies.9.\(index + 1)", comment: "")))
			}
		}
	}
	
}

extension ClaimsProcessVC: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stepsToShow.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ClaimsClaimProcessCell.identifier) as! ClaimsClaimProcessCell
		cell.titleLabel.text = "\(indexPath.row + 1) - \(claimsProcessModels[stepsToShow[indexPath.row]].title)"
		cell.bodyLabel.text = claimsProcessModels[stepsToShow[indexPath.row]].body
		return cell
	}
	
}
