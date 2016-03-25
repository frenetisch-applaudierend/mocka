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

    public func invocationAtIndex(index: Int, handler: (Params) -> Void) {
        if index > 0 && index < self.recordedInvocations.count {
            handler(self.recordedInvocations[index])
        }
    }

    public func firstInvocation(handler: (Params) -> Void) {
        if let invocation = self.recordedInvocations.first {
            handler(invocation)
        }
    }

    public func lastInvocation(handler: (Params) -> Void) {
        if let invocation = self.recordedInvocations.last {
            handler(invocation)
        }
    }

    public func wasCalled(atLeast count: Int = 1) -> Bool {
        return self.wasCalled(atLeast: count, withParameters: AnyMatcher())
    }

    public func wasCalled<M: Matcher where M.Params == Params>(atLeast count: Int = 1, withParameters matcher: M) -> Bool {
        return self.wasCalled(atLeast: count, atMost: nil, matcher: matcher)
    }

    public func wasCalled(exactly count: Int) -> Bool {
        return self.wasCalled(exactly: count, withParameters: AnyMatcher())
    }

    public func wasCalled<M: Matcher where M.Params == Params>(exactly count: Int, withParameters matcher: M) -> Bool {
        return self.wasCalled(atLeast: count, atMost: count, matcher: matcher)
    }

    private func wasCalled<M: Matcher where M.Params == Params>(atLeast minCount: Int?, atMost maxCount: Int?, matcher: M) -> Bool {
        let matchingInvocations = self.recordedInvocations.filter { matcher.matches($0) }

        if let minCount = minCount where minCount > matchingInvocations.count { return false }
        if let maxCount = maxCount where maxCount < matchingInvocations.count { return false }

        return true
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
