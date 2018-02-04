//
// PolicePreQuestionnaireVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/13/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

class PolicePreQuestionnaireVC: FNOLBaseVC, UIValidationDelegate {
    
    var currentSection: Section?
    private var currentField: Field?
    private var dataSource: [String]?
    
    
    @IBOutlet weak var nextButton: CustomButton!
    @IBOutlet weak var policeReportTextField: UITextField!
    @IBOutlet weak var policeLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var policeSegmentedControl: CustomSegmentControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.currentSection?.sectionName
        self.currentField = self.currentSection?.getFieldForType(type:"claim.policeAtScene")
        view.hideKeyboardWhenTapped = true
        errorLabel.text = ""
        formValidator.registerField(policeReportTextField, errorLabel: errorLabel, rules: [AlphaNumericRule()])
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setUpPage()
	}
    
    ///Prepare page with Questionnaire 
    ///
    func setUpPage() {
        policeLabel.numberOfLines = 0
        self.policeSegmentedControl.addTarget(self, action: #selector(segmentSelected(sender: )), for: .valueChanged)
        guard let dataSource =  getCurrentFieldValues() else { return }
        self.dataSource = dataSource
        policeSegmentedControl.items = dataSource
        self.policeLabel.text = self.currentField?.label
		if let policeNumber = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "claim.policeNumber") {
			policeReportTextField.text = policeNumber
		}
		if let responseKey = currentField?.responseKey, let value = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: responseKey) {
			if let value = YesNoUnsure.allValues.index(of: value) {
				policeSegmentedControl.selectedIndex = value
			}
			self.segmentSelected(sender: policeSegmentedControl)
		}
    }
    
    static func instantiate() -> PolicePreQuestionnaireVC {
        let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! PolicePreQuestionnaireVC
        return vc
    }
    
    @objc func segmentSelected(sender: CustomSegmentControl) {
        switch sender.selectedIndex {
        case 0:
            policeReportTextField.isHidden = false
            nextButton.isHidden = false
            policeReportTextField.layer.addBottomBorder(color: .tgGray, thickness: 1.0)
            errorLabel.isHidden = false
        case 1:
            policeReportTextField.isHidden = true
            errorLabel.isHidden = true
            
        case 2:
            policeReportTextField.isHidden = true
            errorLabel.isHidden = true
            
        default:()
        }
        ///Update user selection to Claim
		if sender.selectedIndex >= 0 {
			ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(YesNoUnsure.allValues[sender.selectedIndex], displayValue: YesNoUnsure.allValues[sender.selectedIndex], forResponseKey: "claim.policeAtScene")
			nextButton.isHidden = false
		}

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// On Next Show Next vehicle
    ///
    @IBAction func didTouchonNext(id: UIButton) {
        if policeSegmentedControl.selectedIndex == 0 {
            formValidator.validate(self)
        }else{
            self.performSegue(withIdentifier: "showPreQueVehicleVC", sender: self)
        }
    }
    
    ///Error handling Validation Successful
    ///
    func validationSuccessful() {
        self.performSegue(withIdentifier: "showPreQueVehicleVC", sender: self)
    }
    
    ///Error handling Validation Unsuccessful
    ///
    func validationFailed(_ errors: [(Validatable, ValidationErrorMessage)]) {
        print("Validation failed for \(policeReportTextField)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showPreQueVehicleVC") {
            let vc = segue.destination as! VehiclePreQuestionaireVC
            vc.currentSection = self.currentSection
        }
    }
    
}

extension PolicePreQuestionnaireVC: UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(text, displayValue: nil, forResponseKey: "claim.policeNumber")
        }
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension PolicePreQuestionnaireVC {
    
    //TODO -  Need to custom map can remove later
    func getCurrentFieldValues() -> [String]? {
        
        guard let valueList: [Value] = self.currentField?.validValuesArray
            else {
                return [""]
        }
        let items: [String] = valueList.map({
            (v: Value) -> String in
            if v.code == "i_don't_know" {
                return "Unsure"
            }
            return v.value!
        })
        return items
    }
}
