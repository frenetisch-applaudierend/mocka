//
//  MCKBlockArgumentMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKBlockArgumentMatcher.h"
#import "MCKValueSerialization.h"


@interface MCKBlockArgumentMatcherTest : XCTestCase
@end

@implementation MCKBlockArgumentMatcherTest {
    MCKBlockArgumentMatcher *matcher;
}

#pragma mark - Setup

- (void)setUp {
    matcher = [[MCKBlockArgumentMatcher alloc] init];
}


#pragma mark - Test Cases

- (void)testThatCandidateIsPassedToMatcherBlock {
    // given
    __block NSValue *passedCandiate = nil;
    matcher.matcherBlock = ^BOOL(NSValue *candidate) {
        passedCandiate = candidate;
        return YES;
    };
    
    // when
    NSValue *candidate = MCKSerializeValue(@"Hello World");
    [matcher matchesCandidate:candidate];
    
    // then
    expect(passedCandiate).to.equal(candidate);
}

- (void)testThatMatcherReturnsTrueIfNoMatcherBlockIsSet {
    // given
    matcher.matcherBlock = nil;
    
    // then
    XCTAssertTrue([matcher matchesCandidate:MCKSerializeValue(@"Foo")], @"Matcher should have matched");
}

- (void)testThatMatcherReturnsTrueIfMatcherBlockReturnsTrue {
    // given
    matcher.matcherBlock = ^(id _) { return YES; };
    
    // then
    XCTAssertTrue([matcher matchesCandidate:MCKSerializeValue(@"Foo")], @"Matcher should have matched");
}

- (void)testThatMatcherReturnsFalseIfMatcherBlockReturnsFalse {
    // given
    matcher.matcherBlock = ^(id _) { return NO; };
    
    // then
    XCTAssertFalse([matcher matchesCandidate:MCKSerializeValue(@"Foo")], @"Matcher should not have matched");
}

@end
