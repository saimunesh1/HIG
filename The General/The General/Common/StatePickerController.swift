//
//  StatePickerController.swift
//  The General
//
//  Created by Leif Harrison on 12/7/17.
//  Copyright © 2017 The General. All rights reserved.
//

import Foundation

class StatePickerController: NSObject {

    let stateDictionary: [String: String] = [
        "Alaska": "AK",
        "Alabama": "AL",
        "Arkansas": "AR",
        "American Samoa": "AS",
        "Arizona": "AZ",
        "California": "CA",
        "Colorado": "CO",
        "Connecticut": "CT",
        "District of Columbia": "DC",
        "Delaware": "DE",
        "Florida": "FL",
        "Georgia": "GA",
        "Guam": "GU",
        "Hawaii": "HI",
        "Iowa": "IA",
        "Idaho": "ID",
        "Illinois": "IL",
        "Indiana": "IN",
        "Kansas": "KS",
        "Kentucky": "KY",
        "Louisiana": "LA",
        "Massachusetts": "MA",
        "Maryland": "MD",
        "Maine": "ME",
        "Michigan": "MI",
        "Minnesota": "MN",
        "Missouri": "MO",
        "Mississippi": "MS",
        "Montana": "MT",
        "North Carolina": "NC",
        "North Dakota": "ND",
        "Nebraska": "NE",
        "New Hampshire": "NH",
        "New Jersey": "NJ",
        "New Mexico": "NM",
        "Nevada": "NV",
        "New York": "NY",
        "Ohio": "OH",
        "Oklahoma": "OK",
        "Oregon": "OR",
        "Pennsylvania": "PA",
        "Puerto Rico": "PR",
        "Rhode Island": "RI",
        "South Carolina": "SC",
        "South Dakota": "SD",
        "Tennessee": "TN",
        "Texas": "TX",
        "Utah": "UT",
        "Virginia": "VA",
        "Virgin Islands": "VI",
        "Vermont": "VT",
        "Washington": "WA",
        "Wisconsin": "WI",
        "West Virginia": "WV",
        "Wyoming": "WY"]

    public let pickerView: UIPickerView = UIPickerView()

    public lazy var sortedStateNames: [String] = {
        Array(stateDictionary.keys).sorted()
    }()

    public var textField: UITextField

    //--------------------------------------------------------------------------
    // MARK: - Initialization
    //--------------------------------------------------------------------------

    public init(textField: UITextField) {
        self.textField = textField

        super.init()

        pickerView.backgroundColor = UIColor.tgGray
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.showsSelectionIndicator = true
        self.textField.inputView = pickerView

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.tgGreen
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(pickerDone(_: )))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pickerCancel(_: )))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.textField.inputAccessoryView = toolBar

    }

    //--------------------------------------------------------------------------
    // MARK: - Private
    //--------------------------------------------------------------------------

    private func titleText(forRow row: Int) -> String {
        let stateName = sortedStateNames[row]
        if let abbreviation = stateDictionary[stateName] {
            return "\(abbreviation) - \(stateName)"
        }
        else {
            return "\(stateName)"
        }
    }

    //--------------------------------------------------------------------------
    // MARK: - Actions
    //--------------------------------------------------------------------------

    @objc func pickerDone(_ sender: UIBarButtonItem) {
        let selectedIndex = pickerView.selectedRow(inComponent: 0)
        let stateName = sortedStateNames[selectedIndex]
        textField.text = stateDictionary[stateName]
        if let shouldReturn = textField.delegate?.textFieldShouldReturn?(textField), shouldReturn == true {
            textField.resignFirstResponder()
        }
    }

    @objc func pickerCancel(_ sender: UIBarButtonItem) {
        textField.resignFirstResponder()
    }
}

//==============================================================================
// MARK: - UIPickerViewDataSource
//==============================================================================

extension StatePickerController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortedStateNames.count
    }

}

//==============================================================================
// MARK: - UIPickerViewDelegate
//==============================================================================

extension StatePickerController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleText(forRow: row)
    }

}
