//
//  Dodies_lvUITests.swift
//  Dodies.lvUITests
//
//  Created by Kristaps Grinbergs on 06/11/2016.
//  Copyright © 2016 fassko. All rights reserved.
//

import XCTest

class Dodies_lvUITests: XCTestCase {
        
  override func setUp() {
    super.setUp()
    
    let app = XCUIApplication()
    setupSnapshot(app)
    app.launch()
  }
  
  func testExample() {
    sleep(5)
    snapshot("App launched")
//    XCUIApplication().alerts["Allow “Dodies.lv” to access your location while you use the app?"].buttons["Allow"].tap()
    
  }
    
}
