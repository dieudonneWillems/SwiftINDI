//
//  SwiftINDITests.swift
//  SwiftINDITests
//
//  Created by Don Willems on 12/03/2020.
//  Copyright © 2020 Don Willems. All rights reserved.
//

import XCTest
@testable import SwiftINDI

class SwiftINDITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
<<<<<<< Updated upstream
        let indiClient = BasicClient(host: "localhost", port: 7624)
        indiClient.connect()
=======
        let client = BasicINDIClient(server: "revisionist.local", port: 7624)
        sleep(1)
>>>>>>> Stashed changes
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
