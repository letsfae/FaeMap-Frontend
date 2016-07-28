//
//  faeBetaTests.swift
//  faeBetaTests
//
//  Created by blesssecret on 5/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import XCTest
@testable import faeBeta

class faeBetaTests: XCTestCase {
    
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
        faeUserSignUpTest()
    }
    func faeUserSignUpTest() {
        let user = FaeUser()
        user.whereKey("email", value: "aaa@usc.edu")
        user.whereKey("password", value: "A1234567")
        user.whereKey("first_name", value: "wwwwwwwwwwwwwwwww")
        user.whereKey("last_name", value: "jjjjjj")
        user.whereKey("birthday", value: "1991-12-30")
        user.whereKey("gender", value: "male")
        user.signUpInBackground { (status:Int?, message:AnyObject?) in
            //            print(status)//if status is 201
            XCTAssertTrue(status!/100 == 2)
            if(status!/100 == 2){//success
                print(status)
                print("Sign Up Success!")
                
            }
            else{
                print(status)
                print("Sign Up Fail!")
                XCTFail("sign up test fail!")
            }
        }

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
