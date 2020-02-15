//
//  AppDelegate.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 21/10/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Date.configureDefaults()
        Notification.userConcent(application: application)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        Notification.configure()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
}
