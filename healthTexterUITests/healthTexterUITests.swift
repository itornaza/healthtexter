//
//  healthTexterUITests.swift
//  healthTexterUITests
//
//  Created by Ioannis Tornazakis on 21/10/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import XCTest

/// Caution: On the simulator set, Hardware > Keybord > Connect hardware keyboard
class healthTexterUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_write() {
      let app = XCUIApplication()
      app.buttons["Write"].tap()
      app.textViews["daily_text"].tap()
      let doneButton = app.navigationBars.element.buttons["Done"]
      doneButton.tap()
      doneButton.tap()
      app.navigationBars["Share today's entry"].buttons["Home"].tap()
    }
    
    func test_monitor() {
        let app = XCUIApplication()
        app.buttons["Monitor"].tap()
        
        let sleepButton = app.buttons["Sleep"]
        sleepButton.tap()
        
        let functionalityButton = app.buttons["Functionality"]
        functionalityButton.tap()
        
        let progressButton = app.buttons["Progress"]
        progressButton.tap()
        
        app.buttons["Pain"].tap()
        app.buttons["Last month"].tap()
        sleepButton.tap()
        functionalityButton.tap()
        progressButton.tap()
        app.navigationBars["Share today's entry"].buttons["Home"].tap()
    }
    
    func test_history() {
        // Make sure there is at least one entry in the diary
        let app = XCUIApplication()
        app.buttons["History"].tap()
        app.tables.cells.element.firstMatch.tap()
        app.navigationBars.element.buttons["History"].tap()
        app.navigationBars["History"].buttons["Select"].tap()
    }
    
    func test_preferences() {
        let app = XCUIApplication()
        app.buttons["Preferences"].tap()
        app.navigationBars["Preferences"].buttons["Home"].tap()
    }
    
}
