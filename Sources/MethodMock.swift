//
//  MethodMock.swift
//  Mocka
//
//  Created by Markus Gasser on 24.03.16.
//  Copyright © 2016 konoma GmbH. All rights reserved.
//

import Foundation


public class MethodMock<Params, ReturnValue> {

    // MARK: - Initialization

    private var implementation: (Params) -> ReturnValue

    public init(_ implementation: (Params) -> ReturnValue) {
        self.implementation = implementation
    }

    public convenience init(returnValue: ReturnValue) {
        self.init({ _ in return returnValue })
    }


    // MARK: - Recording

    private var recordedInvocations: [Params] = []

    public func record(params params: Params) -> ReturnValue {
        self.recordedInvocations.append(params)
        return self.implementation(params)
    }


    // MARK: - Stubbing

    public func stub(implementation: (Params) -> ReturnValue) {
        self.implementation = implementation
    }


    // MARK: - Getting Information

    public func wasCalled(atLeast count: Int = 1) -> Bool {
        return self.recordedInvocations.count >= count
    }

    public func wasCalled(exactly count: Int) -> Bool {
        return self.recordedInvocations.count == count
    }
}


public extension MethodMock where ReturnValue: NilLiteralConvertible {

    public convenience init() {
        self.init(returnValue: nil)
    }
}


public extension MethodMock where ReturnValue: StringLiteralConvertible {

    public convenience init() {
        self.init(returnValue: "")
    }
}


public extension MethodMock where ReturnValue: IntegerLiteralConvertible {

    public convenience init() {
        self.init(returnValue: 0)
    }
}


public extension MethodMock where ReturnValue: FloatLiteralConvertible {

    public convenience init() {
        self.init(returnValue: 0.0)
    }
}


public extension Int {

    public static var Once: Int = 1

    public var times: Int { return self }
}
