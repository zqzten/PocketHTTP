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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

