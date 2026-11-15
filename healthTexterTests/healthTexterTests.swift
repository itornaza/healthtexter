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
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.textVC = storyboard.instantiateViewController(withIdentifier: "TextViewController")
            as! healthTexter.TextViewController
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {}
    
    func testPerformanceExample() {
        self.measure {
        }
    }
    
}
