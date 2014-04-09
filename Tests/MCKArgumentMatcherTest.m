//
//  MCKArgumentMatcherTest.m
//  mocka
//
//  Created by Markus Gasser on 22.12.12.
//  Copyright (c) 2012 Markus Gasser. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Mocka.h"
#import "MCKMockingContext.h"
#import "MCKArgumentMatcherRecorder.h"


@interface MCKArgumentMatcherTest : XCTestCase
@end

@implementation MCKArgumentMatcherTest {
    MCKMockingContext *context;
    MCKArgumentMatcherRecorder *recorder;
}

#pragma mark - Setup

- (void)setUp {
    context = [MCKMockingContext currentContext];
    recorder = [context argumentMatcherRecorder];
}


#pragma mark - Test Cases

- (void)testThatObjectArgumentMatcherIsPassedDirectly {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    
    // when
    id matcher = [[MCKBlockArgumentMatcher alloc] init];
    id value = MCKRegisterMatcher(matcher, id);
    
    // then
    XCTAssertTrue(matcher == value, @"Wrong object is returned");
}

- (void)testThatPrimitiveNumberMatcherIndexCanBeRetrievedAgain {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    int value = mck_registerPrimitiveNumberMatcher([[MCKBlockArgumentMatcher alloc] init]);
    
    // then
    expect(MCKMatcherIndexForPrimitiveArgument(&value)).to.equal(([recorder.argumentMatchers count] - 1));
}

- (void)testThatCStringMatcherIndexCanBeRetrievedAgain {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    char *value = mck_registerCStringMatcher([[MCKBlockArgumentMatcher alloc] init]);
    
    // then
    expect(MCKMatcherIndexForPrimitiveArgument(&value)).to.equal(([recorder.argumentMatchers count] - 1));
}

- (void)testThatSelectorMatcherIndexCanBeRetrievedAgain {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    SEL value = mck_registerSelectorMatcher([[MCKBlockArgumentMatcher alloc] init]);
    
    // then
    expect(MCKMatcherIndexForPrimitiveArgument(&value)).to.equal(([recorder.argumentMatchers count] - 1));
}

- (void)testThatPointerMatcherIndexCanBeRetrievedAgain {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    void *value = mck_registerPointerMatcher([[MCKBlockArgumentMatcher alloc] init]);
    
    // then
    expect(MCKMatcherIndexForPrimitiveArgument(&value)).to.equal(([recorder.argumentMatchers count] - 1));
}

- (void)testThatStructMatcherIndexCanBeRetrievedAgain {
    // given
    [context updateContextMode:MCKContextModeStubbing];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    [recorder addPrimitiveArgumentMatcher:[[MCKBlockArgumentMatcher alloc] init]];
    
    // when
    NSRange value = mck_registerStructMatcher([[MCKBlockArgumentMatcher alloc] init], NSRange);
    
    // then
    expect(MCKMatcherIndexForPrimitiveArgument(&value)).to.equal(([recorder.argumentMatchers count] - 1));
}


@end
