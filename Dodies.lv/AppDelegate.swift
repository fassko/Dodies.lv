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
import XCGLogger

let log: XCGLogger = {
  let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
  
  // Create a destination for the system console log (via NSLog)
  let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")
  
  // Optionally set some configuration options
  systemDestination.outputLevel = .debug
  systemDestination.showLogIdentifier = false
  systemDestination.showFunctionName = true
  systemDestination.showThreadName = true
  systemDestination.showLevel = true
  systemDestination.showFileName = true
  systemDestination.showLineNumber = true
  systemDestination.showDate = true
  
  // Add the destination to the logger
  log.add(destination: systemDestination)
  
  return log
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    
    Realm.Configuration.defaultConfiguration = Realm.Configuration(
      schemaVersion: 2,
      migrationBlock: { migration, oldSchemaVersion in
      
        if (oldSchemaVersion < 1) {
          migration.deleteData(forType: DodiesPoint.className())
        }
    })

    let realm = try! Realm()
    
    return true
  }

  private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    Fabric.with([Crashlytics.self])
        
    return true
  }

}
