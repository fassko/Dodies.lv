//
//  AppDelegate.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import UIKit

import Fabric
import Crashlytics
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var coordinator: MainCoordinator?
  
  func application(_ application: UIApplication,
                   willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
    
    Realm.Configuration.defaultConfiguration = Realm.Configuration(
      schemaVersion: 4,
      migrationBlock: { migration, oldSchemaVersion in
        if oldSchemaVersion < 1 {
          migration.deleteData(forType: DodiesPoint.className())
        }
    })
    
    do {
      _ = try Realm()
    } catch {
      print("Can't load Realm")
    }
    
    let navController = UINavigationController()
    navController.navigationBar.barTintColor = UIColor(red: 0.42, green: 0.60, blue: 0.23, alpha: 1.0)
    navController.navigationBar.tintColor = .white
    
    coordinator = MainCoordinator(navigationController: navController)
    coordinator?.start()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = navController
    window?.makeKeyAndVisible()
    
    return true
  }
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
    Fabric.with([Crashlytics.self])
    
    return true
  }

}
