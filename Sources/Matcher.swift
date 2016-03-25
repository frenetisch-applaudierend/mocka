//
//  Matcher.swift
//  Mocka
//
//  Created by Markus Gasser on 25.03.16.
//  Copyright © 2016 konoma GmbH. All rights reserved.
//

import Foundation


public protocol Matcher {

    associatedtype Params

    func matches(params: Params) -> Bool
}


public class AnyMatcher<Params>: Matcher {

    public func matches(params: Params) -> Bool {
        return true
    }
}


public class BlockMatcher<Params>: Matcher {

    private let matcherBlock: (Params) -> Bool

    public init(matcherBlock: (Params) -> Bool) {
        self.matcherBlock = matcherBlock
    }

    public func matches(params: Params) -> Bool {
        return self.matcherBlock(params)
    }
}


public func matching<Params>(block: (Params) -> Bool) -> BlockMatcher<Params> {
    return BlockMatcher(matcherBlock: block)
}

public func eq<T1: Equatable>(p1: T1) -> BlockMatcher<T1> {
    return BlockMatcher(matcherBlock: { c1 in c1 == p1 })
}

public func eq<T1: Equatable, T2: Equatable>(p1: T1, _ p2: T2) -> BlockMatcher<(T1, T2)> {
    return BlockMatcher(matcherBlock: { c1, c2 in c1 == p1 && c2 == p2 })
}

public func eq<T1: Equatable, T2: Equatable, T3: Equatable>(p1: T1, _ p2: T2, _ p3: T3) -> BlockMatcher<(T1, T2, T3)> {
    return BlockMatcher(matcherBlock: { c1, c2, c3 in c1 == p1 && c2 == p2 && c3 == p3 })
}

public func eq<T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable>(p1: T1, _ p2: T2, _ p3: T3, _ p4: T4) -> BlockMatcher<(T1, T2, T3, T4)> {
    return BlockMatcher(matcherBlock: { c1, c2, c3, c4 in c1 == p1 && c2 == p2 && c3 == p3 && c4 == p4 })
}
