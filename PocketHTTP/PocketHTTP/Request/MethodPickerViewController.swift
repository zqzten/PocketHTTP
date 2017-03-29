//
//  MethodPickerViewController.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/1/26.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit

class MethodPickerViewController: UITableViewController {

    var selectedMethod: PHMethod!
    private var selectedIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, method) in PHMethod.allValues.enumerated() {
            if method == selectedMethod {
                selectedIndexPath = IndexPath(row: index, section: 0)
                break
            }
        }
        
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PHMethod.allValues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell", for: indexPath)
        let method = PHMethod.allValues[indexPath.row]
        cell.textLabel!.text = method.rawValue
        cell.accessoryType = method == selectedMethod ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            selectedIndexPath = indexPath
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedMethod" {
            selectedMethod = PHMethod.allValues[tableView.indexPath(for: sender as! UITableViewCell)!.row]
        }
    }

}
