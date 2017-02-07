//
//  AppDelegate.swift
//  PocketHTTP
//
//  Created by 朱子秋 on 2017/1/26.
//  Copyright © 2017年 朱子秋. All rights reserved.
//

import UIKit
import CoreData
import AlamofireNetworkActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Could not load data store: \(error)")
            }
        }
        return container
    }()

    private lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // let Alamofire take care of the network activity indicator
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        // register user defaults
        let defaultDict: [String: Any] = ["SendNoCacheHeader": false, "UseDeviceUserAgent": false, "UseDarkTheme": false, "HistoryLimit": 30]
        UserDefaults.standard.register(defaults: defaultDict)
        
        // pass down core data context
        let tabBarController = window!.rootViewController as! UITabBarController
        if let tabBarViewControllers = tabBarController.viewControllers {
            var navigationController = tabBarViewControllers[0] as! UINavigationController
            let requestViewController = navigationController.viewControllers[0] as! RequestViewController
            requestViewController.managedObjectContext = managedObjectContext
            navigationController = tabBarViewControllers[1] as! UINavigationController
            let bookmarksViewController = navigationController.viewControllers[0] as! BookmarksViewController
            bookmarksViewController.managedObjectContext = managedObjectContext
            bookmarksViewController.requestViewController = requestViewController
            navigationController = tabBarViewControllers[2] as! UINavigationController
            let preferencesViewController = navigationController.viewControllers[0] as! PreferencesViewController
            preferencesViewController.managedObjectContext = managedObjectContext
        }
        
        // customize appearance
        let tintColor = UIColor(red: 246/255.0, green: 113/255.0, blue: 46/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
        
        return true
    }

}

