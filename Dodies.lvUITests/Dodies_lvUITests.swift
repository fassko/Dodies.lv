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
    sleep(3)
//    XCUIApplication().alerts["Allow “Dodies.lv” to access your location while you are using the app?"].buttons["Allow"].tap()
    snapshot("App launched")
    
    let app = XCUIApplication()
    
    let b = app.otherElements["Map"].buttons["Ogres zilie kalni"]
    
    
    b.tap()
    
    sleep(10)
    
    print(app.debugDescription)
    
    
    


//    app.buttons["More info"].tap()
    
//    app/*@START_MENU_TOKEN@*/.otherElements["Map"].buttons["Ogres zilie kalni"]/*[[".otherElements[\"Map\"].buttons[\"Ogres zilie kalni\"]",".buttons[\"Ogres zilie kalni\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
    
//    let mapButton = app/*@START_MENU_TOKEN@*/.buttons["Map"]/*[[".otherElements[\"Map\"].buttons[\"Map\"]",".buttons[\"Map\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//    mapButton.tap()
//    mapButton.tap()
//    app/*@START_MENU_TOKEN@*/.otherElements["Map"].buttons["More Info"]/*[[".otherElements[\"Map\"].buttons[\"More Info\"]",".buttons[\"More Info\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
    
//    XCUIApplication().alerts["Allow “Dodies.lv” to access your location while you use the app?"].buttons["Allow"].tap()
    
  }
    
}
