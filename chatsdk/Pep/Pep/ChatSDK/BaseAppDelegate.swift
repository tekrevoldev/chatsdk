//
//  AppDelegate.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 05/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

class BaseAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        Database.database().reference().keepSynced(true)
        FirebaseConfiguration().setLoggerLevel(.error)
        IQKeyboardManager.shared.enable = true

        setupUX()
        
        return true
    }

    func setupUX() {
        if AppStateManager.sharedInstance.isUserLogin() {
            presentHomeViewController()
        } else {
            presentLoginViewController()
        }
    }
    
    func presentLoginViewController() {
        self.window?.rootViewController = AppStoryboard.Authetication.initialViewController()
    }
    
    func presentHomeViewController() {
        self.window?.rootViewController = AppStoryboard.Home.initialViewController()
    }
}

