//
//  healthTexterTests.swift
//  healthTexterTests
//
//  Created by Ioannis Tornazakis on 21/10/15.
//  Copyright © 2015 polarbear.gr. All rights reserved.
//

import XCTest
@testable import healthTexter

class healthTexterTests: XCTestCase {
    
    // Controllers to test
    var textVC = healthTexter.TextViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.textVC = storyboard.instantiateViewControllerWithIdentifier("TextViewController")
            as! healthTexter.TextViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}