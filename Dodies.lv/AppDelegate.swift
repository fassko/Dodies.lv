//
//  AppDelegate.swift
//  Dodies.lv
//
//  Created by Kristaps Grinbergs on 13/09/15.
//  Copyright © 2015 fassko. All rights reserved.
//

import UIKit

import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var coordinator: MainCoordinator?
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    Realm.Configuration.defaultConfiguration = Realm.Configuration(
      schemaVersion: 6,
      migrationBlock: { migration, oldSchemaVersion in
        if oldSchemaVersion < 6 {
          migration.deleteData(forType: DodiesPoint.className())
        }
    })
    
    do {
      _ = try Realm()
    } catch {
      fatalError("Can't load Realm")
    }
    
    let navController = UINavigationController()
    navController.navigationBar.barTintColor = Constants.greenColor
    navController.navigationBar.tintColor = .white
    navController.navigationBar.isTranslucent = true
    
    coordinator = MainCoordinator(navigationController: navController)
    coordinator?.start()
    
    window = UIWindow()
    window?.rootViewController = navController
    window?.makeKeyAndVisible()
    
    return true
  }

}
