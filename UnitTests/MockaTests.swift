//
//  MockaTests.swift
//  MockaTests
//
//  Created by Markus Gasser on 24.03.16.
//  Copyright © 2016 konoma GmbH. All rights reserved.
//

import XCTest
import Mocka


class MockaTests: XCTestCase {

    var testClass: MockTestClass!

    override func setUp() {
        super.setUp()

        MockaConfig.failureReporter = { message, file, line in
            XCTFail(message, file: file, line: line)
        }

        self.testClass = MockTestClass()
    }
    
    func testExample() {
        self.testClass.testMethodMock.stub { return 20 }
        self.testClass.testMethodValueMock.stub { _ in return 30 }

        XCTAssertEqual((self.testClass as TestClass).testMethod(), 20)
        XCTAssertEqual((self.testClass as TestClass).testMethod(20), 30)
        XCTAssertEqual((self.testClass as TestClass).testMethod(200), 30)

        self.testClass.testMethod(100, name: "")


        self.testClass.testMethodMock.verify()

        self.testClass.testMethodValueMock.verifyLast { value in
            XCTAssert(value > 100)
        }

        self.testClass.testMethodMultipleMock.verifyLast { value, name in
            XCTAssert(value > 10)
            XCTAssert(name.isEmpty)
        }
    }
}


class TestClass {

    func testMethod() -> Int {
        return 10
    }

    func testMethod(value: Int) -> Int {
        return 10 * value
    }

    func testMethod(value: Int, name: String) -> Int? {
        return value
    }
}

class MockTestClass: TestClass {

    let testMethodMock = MethodMock<Void, Int>()
    let testMethodValueMock = MethodMock<Int, Int>()
    let testMethodMultipleMock = MethodMock<(Int, String), Int?>()


    override func testMethod() -> Int {
        return self.testMethodMock.record(params: ())
    }

    override func testMethod(value: Int) -> Int {
        return self.testMethodValueMock.record(params: value)
    }

    override func testMethod(value: Int, name: String) -> Int? {
        return self.testMethodMultipleMock.record(params: (value, name))
    }
}
