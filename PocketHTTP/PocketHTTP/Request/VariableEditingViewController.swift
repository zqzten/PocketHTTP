//
//  VariableEditingViewController.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/2/1.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit
import CoreData

class VariableEditingViewController: UITableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var managedObjectContext: NSManagedObjectContext!
    var variable: PHVariable?
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let variableToSave = variable == nil ? PHVariable(context: managedObjectContext) : variable!
        variableToSave.name = nameTextField.text!
        variableToSave.value = valueTextField.text!
        do {
            try managedObjectContext.save()
        } catch {
            let error = error as NSError
            if error.code == 133021 {
                let alert = UIAlertController(title: "Name Conflict", message: "Variable's name already existed, try another name.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.nameTextField.becomeFirstResponder()
                }
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
            } else {
                fatalError("Could not save data: \(error)")
            }
        }
        performSegue(withIdentifier: "EditedVariable", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let variable = variable {
            title = "Edit Variable"
            nameTextField.text = variable.name
            valueTextField.text = variable.value
        } else {
            title = "Add Variable"
        }
    }

}

extension VariableEditingViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        if textField == nameTextField {
            saveButton.isEnabled = newText.length > 0
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            valueTextField.becomeFirstResponder()
        } else {
            valueTextField.resignFirstResponder()
        }
        return true
    }
    
}
