//
//  HistoryLimitPickerViewController.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/2/2.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit

class HistoryLimitPickerViewController: UITableViewController {

    private let historyLimits = [15, 30, 50, 100, 0]
    var selectedHistoryLimit: Int!
    private var selectedIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, limit) in historyLimits.enumerated() {
            if limit == selectedHistoryLimit {
                selectedIndexPath = IndexPath(row: index, section: 0)
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyLimits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryLimitCell", for: indexPath)
        let limit = historyLimits[indexPath.row]
        cell.textLabel!.text = limit == 0 ? "No limit" : String(limit)
        cell.accessoryType = limit == selectedHistoryLimit ? .checkmark : .none
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
        if segue.identifier == "PickedHistoryLimit" {
            selectedHistoryLimit = historyLimits[tableView.indexPath(for: sender as! UITableViewCell)!.row]
        }
    }

}
