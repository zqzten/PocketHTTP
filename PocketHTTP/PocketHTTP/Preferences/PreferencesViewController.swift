//
//  PreferencesViewController.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/2/2.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit
import CoreData

class PreferencesViewController: UITableViewController {

    @IBOutlet weak var sendNoCacheHeaderSwitch: UISwitch!
    @IBOutlet weak var useDeviceUserAgentSwitch: UISwitch!
    @IBOutlet weak var useDarkThemeSwitch: UISwitch!
    @IBOutlet weak var historyLimitLabel: UILabel!
    
    var managedObjectContext: NSManagedObjectContext!
    lazy var userDefaults = UserDefaults.standard
    
    var historyLimit: Int! {
        didSet {
            if historyLimit != 0 {
                let fetchRequest: NSFetchRequest<PHRequest> = PHRequest.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == nil")
                do {
                    let historyCount = try managedObjectContext.count(for: fetchRequest)
                    if historyCount > historyLimit {
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
                        fetchRequest.fetchLimit = historyCount - historyLimit
                        let historyToDelete = try managedObjectContext.fetch(fetchRequest)
                        for history in historyToDelete {
                            managedObjectContext.delete(history)
                        }
                        try managedObjectContext.save()
                    }
                } catch {
                    fatalError("Could not tailor data: \(error)")
                }
            }
            userDefaults.set(historyLimit, forKey: "HistoryLimit")
            userDefaults.synchronize()
        }
    }
    
    @IBAction func sendNoCacheHeaderToggled(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: "SendNoCacheHeader")
        userDefaults.synchronize()
    }
    
    @IBAction func useDeviceUserAgentToggled(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: "UseDeviceUserAgent")
        userDefaults.synchronize()
    }
    
    @IBAction func useDarkThemeToggled(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: "UseDarkTheme")
        userDefaults.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sendNoCacheHeaderSwitch.isOn = userDefaults.bool(forKey: "SendNoCacheHeader")
        useDeviceUserAgentSwitch.isOn = userDefaults.bool(forKey: "UseDeviceUserAgent")
        useDarkThemeSwitch.isOn = userDefaults.bool(forKey: "UseDarkTheme")
        historyLimit = userDefaults.integer(forKey: "HistoryLimit")
        historyLimitLabel.text = String(historyLimit)
    }
    
    @IBAction func historyLimitPickerDidPickLimit(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! HistoryLimitPickerViewController
        historyLimit = controller.selectedHistoryLimit
        historyLimitLabel.text = historyLimit == 0 ? "No limit" : String(historyLimit)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickHistoryLimit" {
            let controller = segue.destination as! HistoryLimitPickerViewController
            controller.selectedHistoryLimit = historyLimit
        }
    }

}
