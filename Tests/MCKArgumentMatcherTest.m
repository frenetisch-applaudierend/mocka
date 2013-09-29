//
//  MCKArgumentMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCKArgumentMatcher.h"
#import "MCKBlockArgumentMatcher.h"
#import "MCKArgumentMatcherCollection.h"


@interface MCKArgumentMatcherTest : XCTestCase
@end

@implementation MCKArgumentMatcherTest

#pragma mark - Setup

- (void)setUp {
    [MCKMockingContext contextForTestCase:self]; // setup a context
}


#pragma mark - Test Cases

- (void)testThatObjectArgumentMatcherIsPassedDirectly {
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    id value = mck_registerObjectMatcher(matcher);
    XCTAssertTrue(matcher == value, @"Wrong object is returned");
}

- (void)testThatPrimitiveNumberMatcherIndexCanBeRetrievedAgain {
    // given
    [[MCKMockingContext currentContext] updateContextMode:MCKContextModeStubbing];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    UInt8 value = mck_registerPrimitiveNumberMatcher([[MCKBlockArgumentMatcher alloc] init]);
    
    // then
    XCTAssertEqual((int)mck_matcherIndexForArgumentBytes(&value, @encode(id)),
                   (int)[[[MCKMockingContext currentContext] argumentMatchers] lastPrimitiveArgumentMatcherIndex],
                   @"Wrong index returned");
}

- (void)testThatCStringMatcherIndexCanBeRetrievedAgain {
    // given
    [[MCKMockingContext currentContext] updateContextMode:MCKContextModeStubbing];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    char *value = mck_registerCStringMatcher([[MCKBlockArgumentMatcher alloc] init], MCKDefaultCStringBuffer);
    
    // then
    XCTAssertEqual((int)mck_matcherIndexForArgumentBytes(&value, @encode(char*)),
                   (int)[[[MCKMockingContext currentContext] argumentMatchers] lastPrimitiveArgumentMatcherIndex],
                   @"Wrong index returned");
}

- (void)testThatSelectorMatcherIndexCanBeRetrievedAgain {
    // given
    [[MCKMockingContext currentContext] updateContextMode:MCKContextModeStubbing];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    SEL value = mck_registerSelectorMatcher([[MCKBlockArgumentMatcher alloc] init]);
    
    // then
    XCTAssertEqual((int)mck_matcherIndexForArgumentBytes(&value, @encode(SEL)),
                   (int)[[[MCKMockingContext currentContext] argumentMatchers] lastPrimitiveArgumentMatcherIndex],
                   @"Wrong index returned");
}

- (void)testThatPointerMatcherIndexCanBeRetrievedAgain {
    // given
    [[MCKMockingContext currentContext] updateContextMode:MCKContextModeStubbing];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    void *value = mck_registerPointerMatcher([[MCKBlockArgumentMatcher alloc] init]);
    
    // then
    XCTAssertEqual((int)mck_matcherIndexForArgumentBytes(&value, @encode(void*)),
                   (int)[[[MCKMockingContext currentContext] argumentMatchers] lastPrimitiveArgumentMatcherIndex],
                   @"Wrong index returned");
}

- (void)testThatStructMatcherIndexCanBeRetrievedAgain {
    // given
    [[MCKMockingContext currentContext] updateContextMode:MCKContextModeStubbing];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [[[MCKMockingContext currentContext] argumentMatchers] addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    NSRange value = mck_registerStructMatcher([[MCKBlockArgumentMatcher alloc] init], NSRange);
    
    // then
    XCTAssertEqual((int)mck_matcherIndexForArgumentBytes(&value, @encode(NSRange)),
                   (int)[[[MCKMockingContext currentContext] argumentMatchers] lastPrimitiveArgumentMatcherIndex],
                   @"Wrong index returned");
}


@end
