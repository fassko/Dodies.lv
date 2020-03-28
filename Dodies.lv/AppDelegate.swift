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
      schemaVersion: 7,
      migrationBlock: { migration, oldSchemaVersion in
        if oldSchemaVersion < 7 {
          migration.deleteData(forType: DodiesPoint.className())
        }
    })
    
    do {
      _ = try Realm()
    } catch {
      fatalError("Can't load Realm")
    }
    
    window = UIWindow()
    coordinator = MainCoordinator(window: window)
    coordinator?.start()
    window?.makeKeyAndVisible()
    
    return true
  }

}
