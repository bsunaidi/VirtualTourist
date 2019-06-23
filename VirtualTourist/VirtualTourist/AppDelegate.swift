//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Bushra AlSunaidi on 6/17/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DataController.shared.load()
        return true
    }
    
    func saveViewContext() {
        try? DataController.shared.viewContext.save()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveViewContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveViewContext()
    }
    
}
