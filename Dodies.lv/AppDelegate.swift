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
import CocoaLumberjack
import RealmSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    Fabric.with([Crashlytics.self])
    
    DDLog.addLogger(DDTTYLogger.sharedInstance()) // TTY = Xcode console
    DDLog.addLogger(DDASLLogger.sharedInstance()) // ASL = Apple System Logs
    
    // Configure tracker from GoogleService-Info.plist.
    var configureError:NSError?
    GGLContext.sharedInstance().configureWithError(&configureError)
    assert(configureError == nil, "Error configuring Google services: \(configureError)")

    // Optional: configure GAI options.
    var gai = GAI.sharedInstance()
    gai.trackUncaughtExceptions = true  // report uncaught exceptions
    gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
    
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    UINavigationBar.appearance().barStyle = .Black
    
    let config = Realm.Configuration(
    schemaVersion: 1,

    
    migrationBlock: { migration, oldSchemaVersion in
      // We haven’t migrated anything yet, so oldSchemaVersion == 0
      if (oldSchemaVersion < 1) {
        // Nothing to do!
        // Realm will automatically detect new properties and removed properties
        // And will update the schema on disk automatically
      }
    })

    Realm.Configuration.defaultConfiguration = config

    let realm = try! Realm()
    
    return true
  }


}
