//
//  healthTexterUITests.swift
//  healthTexterUITests
//
//  Created by Ioannis Tornazakis on 21/10/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import XCTest

class healthTexterUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_write() {
        let app = XCUIApplication()
        app.buttons["Write"].tap()
        
        let element = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        element.childrenMatchingType(.TextView).element.tap()
        element.childrenMatchingType(.TextView).element
        
        let doneButton = app.navigationBars.element.buttons["Done"]
        doneButton.tap()
        
        doneButton.tap()
        app.navigationBars.element.buttons["Home"].tap()
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
        let app = XCUIApplication()
        app.buttons["History"].tap()
        app.tables.cells.element.tap()
        
        app.switches["0"].tap()
        app.navigationBars.element.buttons["History"].tap()
        app.navigationBars["History"].buttons["Select"].tap()
    }
    
    func test_preferences() {
        let app = XCUIApplication()
        app.buttons["Preferences"].tap()
        app.navigationBars["Preferences"].buttons["Home"].tap()
    }
    
}
