//
//  DateTests.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 2/4/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//

import XCTest
@testable import healthTexter

class DateTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /// Dates are not equal down to small fractions but their strings should be equal
    func test_get() {
        XCTAssertTrue("\(Date.get())" == "\(NSDate().dateByAddingTimeInterval(-14400))")
    }
    
    /// Default notifications are set at 19:00
    func test_getTimePreference() {
        XCTAssertTrue(Date.getTimePreference() == 68400)
    }
    
    /// Default day switch is set at 04:00
    func test_getDaySwitchPreference() {
        XCTAssertTrue(Date.getDaySwitchPreference() == 14400)
    }
    
    func test_setTimePreference() {
        Date.setTimePreference(3600)
        XCTAssertTrue(Date.getTimePreference() == 3600)
        
        // Set it back to 19:00 for next tests
        Date.setTimePreference(68400)
    }
    
    func test_setDaySwitchPreference() {
        Date.setDaySwitchPreference(3600)
        XCTAssertTrue(Date.getDaySwitchPreference() == 3600)
        
        // Set it back to 04:00 for nex tests
         Date.setDaySwitchPreference(14400)
    }
    
    /// The appDelegate has already marked that the app has launched once
    func test_appHasLaunchedOnce() {
        XCTAssertTrue(Date.appHasLaunchedOnce())
    }
}
