//
//  MCKHamcrestArgumentMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 21.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MCKHamcrestArgumentMatcher.h"
#import "HCBlockMatcher.h"


@interface MCKHamcrestArgumentMatcherTest : SenTestCase
@end

@implementation MCKHamcrestArgumentMatcherTest {
    MCKHamcrestArgumentMatcher *matcher;
}

#pragma mark - Setup

- (void)setUp {
    matcher = [[MCKHamcrestArgumentMatcher alloc] init];
}


#pragma mark - Test Cases

- (void)testThatMatcherCallsHamcrestMatcherWithPassedCandidate {
    // given
    __block id passedCandidate = nil;
    matcher.hamcrestMatcher = [HCBlockMatcher matcherWithBlock:^BOOL(id candidate) {
        passedCandidate = candidate;
        return NO;
    }];
    
    // when
    [matcher matchesCandidate:@"Hello World"];
    
    // then
    STAssertEqualObjects(passedCandidate, @"Hello World", @"Wrong candidate matched");
}

- (void)testThatMatcherReturnsTrueIfNoHamcrestMatcherIsSet {
    // given
    matcher.hamcrestMatcher = nil;
    
    // then
    STAssertTrue([matcher matchesCandidate:@"Foo"], @"Matcher should have matched");
}

- (void)testThatMatcherReturnsTrueIfHamcrestMatcherReturnsTrue {
    // given
    matcher.hamcrestMatcher = [HCBlockMatcher matcherWithBlock:^(id _) { return YES; }];
    
    // then
    STAssertTrue([matcher matchesCandidate:@"Foo"], @"Matcher should have matched");
}

- (void)testThatMatcherReturnsFalseIfHamcrestMatcherReturnsFalse {
    // given
    matcher.hamcrestMatcher = [HCBlockMatcher matcherWithBlock:^(id _) { return NO; }];
    
    // then
    STAssertFalse([matcher matchesCandidate:@"Foo"], @"Matcher should not have matched");
}

@end
