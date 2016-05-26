//
//  VerificationTest.swift
//  faeBeta
//
//  Created by blesssecret on 5/26/16.
//  Copyright © 2016 fae. All rights reserved.
//

import XCTest
@testable import faeBeta

class VerificationTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // MARK: email Verification
        let validEmails = ["tianming@usc.edu", "mingjie@gmail.com"]
        let invalidEmails = ["123!@org.com","123123"]
        for validEmail in validEmails {
            XCTAssertEqual(emailVerification(validEmail), true)
        }
        for invalidEmail in invalidEmails {
            XCTAssertEqual(emailVerification(invalidEmail), false)
        }
        //

    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
