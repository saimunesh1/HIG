//
//  AccidentPreQuestionnairePeopleVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/13/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PeoplePreQuestionnaireVC: FNOLBaseVC {

    var currentSection: Section?
    var currentField: Field?
    var pickerData: [Value] = []
    
    @IBOutlet weak var howManyPeopleLabel: UILabel!
    @IBOutlet weak var peopleCountLabel: UILabel!
    @IBOutlet weak var howManyPeoplePickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        currentField = self.currentSection?.getFieldForType(type:"claim.personCount")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		self.setupPage()

        // Handles removing the top-bar when user navigates back
        if let topBarView = ApplicationContext.shared.fnolClaimsManager.topBarView {
            self.supplementalNavigationController?.removeSupplementalView(topBarView, animated: false)
        }
    }
    
    func setupPage() {
        pickerData = (self.currentField?.getFieldValues())!
        howManyPeoplePickerView.delegate = self
        howManyPeoplePickerView.dataSource = self
        howManyPeopleLabel.text = currentField?.label
        setDefaultValue()
    }
 
    func setDefaultValue() {
		var index: Int?
		if let selection = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "claim.personCount") {
			for (i, value) in pickerData.enumerated() {
				if value.value == selection { index = i }
			}
		}
		if index == nil { index = defaultIndex }
		howManyPeoplePickerView.selectRow(index!, inComponent: 0, animated: false)
		ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(pickerData[index!].code!, displayValue: nil, forResponseKey: (currentField?.responseKey)!)
		peopleCountLabel.text = pickerData[index!].value
    }
    
   static func instantiate() -> PeoplePreQuestionnaireVC {
        let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! PeoplePreQuestionnaireVC
        return vc
    }
    
    @IBAction func didTouchonNext(id: UIButton) {
        let accidentDetails = AccidentDetailsContainerVC.instantiate()
        accidentDetails.viewModel = ApplicationContext.shared.fnolClaimsManager.activeQuestionnaire
        self.navigationController?.pushViewController(accidentDetails, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PeoplePreQuestionnaireVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        peopleCountLabel.text = pickerData[row].value
        ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(pickerData[row].code!, displayValue: nil, forResponseKey: "claim.personCount")
    }
}

extension PeoplePreQuestionnaireVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].value
    }
}
