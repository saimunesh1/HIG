//
//  VehiclePreQuestionaireVC.swift
//  The General
//
//  Created by Gollahalli Chowdappa, Shrikanth (US - New York) on 10/13/17.
//  Copyright © 2017 The General. All rights reserved.
//

import UIKit

let defaultIndex = 1

class VehiclePreQuestionaireVC: FNOLBaseVC {
    
    var currentSection: Section?
    var currentField: Field?
    
    var pickerData: [Value] = []
    
    @IBOutlet var contactUsLabel: UILabel!
    @IBOutlet weak var howManyVehiclesLabel: UILabel!
    @IBOutlet weak var vehicleCountLabel: UILabel!
    @IBOutlet weak var howManyVehiclesPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentField = self.currentSection?.getFieldForType(type:"claim.vehicleCount")
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.setupPage()
	}
    
    func setupPage() {
        pickerData = (self.currentField?.getFieldValues())!
        howManyVehiclesPickerView.delegate = self
        howManyVehiclesPickerView.dataSource = self
        howManyVehiclesLabel.text = self.currentField?.label
        
        let attributedString = NSMutableAttributedString(string: "If more than 5 cars were involved in the accident, please contact us.")
        attributedString.setColorForText("contact us.", with: UIColor.tgGreen)
        self.contactUsLabel.attributedText = attributedString
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(tap: )))
        self.contactUsLabel.addGestureRecognizer(tap)
        self.contactUsLabel.isUserInteractionEnabled = true
        
        setDefaultValue()
    }
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        guard let range = self.contactUsLabel.text?.range(of: "contact us.")?.nsRange else { return }
        if tap.didTapAttributedTextInLabel(label: self.contactUsLabel, inRange: range) {
             self.performSegue(withIdentifier: "showSupportVC", sender: self)
        }
    }
  
    static func instantiate() -> VehiclePreQuestionaireVC {
        let storyboard = UIStoryboard(name: "FNOL", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! VehiclePreQuestionaireVC
        return vc
    }
    
    func setDefaultValue() {
		var index: Int?
		if let selection = ApplicationContext.shared.fnolClaimsManager.activeClaim?.value(forResponseKey: "claim.vehicleCount") {
			for (i, value) in pickerData.enumerated() {
				if value.code == selection { index = i }
			}
		}
		if index == nil { index = defaultIndex }
		howManyVehiclesPickerView.selectRow(index!, inComponent: 0, animated: false)
        ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(pickerData[index!].code!, displayValue: nil, forResponseKey: (currentField?.responseKey)!)
        vehicleCountLabel.text = pickerData[index!].value
    }
    
    @IBAction func didTouchonNext(id: UIButton) {
        self.performSegue(withIdentifier: "PreQuePeopleVCSegueID", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "PreQuePeopleVCSegueID") {
            let vc = segue.destination as! PeoplePreQuestionnaireVC
            vc.currentSection = self.currentSection
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension VehiclePreQuestionaireVC: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        vehicleCountLabel.text = pickerData[row].value
        ApplicationContext.shared.fnolClaimsManager.activeClaim?.setValue(pickerData[row].code!, displayValue: nil, forResponseKey: "claim.vehicleCount")
    }
}

extension VehiclePreQuestionaireVC: UIPickerViewDataSource {
    
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

extension VehiclePreQuestionaireVC {
    
    func getCurrentFieldValues() -> [Value]? {
        
        guard let valueList: [Value] = self.currentField?.validValuesArray
            else {
                return []
        }
       
        return valueList
    }
}
