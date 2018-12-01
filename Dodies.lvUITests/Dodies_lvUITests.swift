//
//  Dodies_lvUITests.swift
//  Dodies.lvUITests
//
//  Created by Kristaps Grinbergs on 06/11/2016.
//  Copyright © 2016 fassko. All rights reserved.
//

import XCTest

class DodiesLVUITests: XCTestCase {
  
  var app: XCUIApplication!
  var counter = 0
  
  override func setUp() {
    super.setUp()
    
    app = XCUIApplication()
    setupSnapshot(app)
    continueAfterFailure = false
    
    app.launchArguments.append("-UITest")
    
    addUIInterruptionMonitor(withDescription: "Location Dialog") { (alert) -> Bool in
      alert.buttons["Allow"].tap()
      return true
    }
  }
  
  func testMainScreen() {
    launchApp()
    
    takeScreenShot("Dodies_main_screen")
    
    let predicate = NSPredicate(format: "label BEGINSWITH '\("Kartavkalna taka")'")
    let annotation = app.otherElements.matching(predicate).element(boundBy: 0)
    
    annotation.tap()
    
    XCTAssertTrue(annotation.waitForExistence(timeout: 1))
    
    takeScreenShot("Observation_Data_Kartavkalna_taka")
  }
  
  private func launchApp() {
    app.launch()
    sleep(5)
  }
  
  fileprivate func takeScreenShot(_ name: String) {
    snapshot("\(String(format: "%02d", counter))_\(name)")
    counter += 1
  }
    
}

extension XCTestCase {
  
  @discardableResult
  func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
    let predicate = NSPredicate(format: "exists == true")
    let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
    let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
    return result == .completed
  }
}
