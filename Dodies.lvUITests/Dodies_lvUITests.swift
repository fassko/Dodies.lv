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
    
    addUIInterruptionMonitor(withDescription: "Location Dialog") { (alert) -> Bool in
      alert.buttons["Allow"].tap()
      return true
    }
  }
  
  func testExample() {
    sleep(5)
  }
    
}
