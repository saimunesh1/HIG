//
//  ChangePasswordTableVC.swift
//  The General
//
//  Created by Bejjavarapu, Sai Munesh (US - Denver) on 1/19/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

class ChangePasswordTableVC: UITableViewController {

    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var reenterPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        textFieldChangeListeners()

        updateSaveBtn()
    }

    @IBAction func cancelTouched(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTouched(_ sender: UIBarButtonItem) {
        let requestBody: [String: String] = [
            "currentPassword": currentPasswordTextField.text ?? "",
            "newPassword": newPasswordTextField.text ?? ""
        ]
        ApplicationContext.shared.profileManager.updatePassword(with: requestBody) { [weak self] (_) in
            guard let sSelf = self else { return }
            sSelf.navigationController?.popViewController(animated: true)
        }
    }
    
    private func textFieldChangeListeners() {
        currentPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
        newPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
        reenterPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_: )), for: .editingChanged)
    }
    
    private func updateSaveBtn() {
        saveBtn.isEnabled = reenterPasswordTextField.hasText && newPasswordTextField.hasText && currentPasswordTextField.hasText && (newPasswordTextField.text == reenterPasswordTextField.text)
    }
}

extension ChangePasswordTableVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateSaveBtn()
    }
}
