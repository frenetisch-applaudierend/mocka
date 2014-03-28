//
//  MCKVerificationTest.m
//  mocka
//
//  Created by Markus Gasser on 28.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKVerification.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKAPIMisuse.h"


@interface MCKVerificationTest : XCTestCase @end
@implementation MCKVerificationTest {
    MCKVerification *verification;
}

#pragma mark - Setup

- (void)setUp {
    verification = [[MCKVerification alloc] initWithVerificationBlock:nil location:nil];
}


#pragma mark - Test Default Values

- (void)testThatInitiallyTheDefaultHandlerIsSet
{
    expect(verification.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}

- (void)testThatInitiallyNoTimeoutIsSet
{
    expect(verification.timeout).to.equal(0.0);
}


#pragma mark - Test Updating Values

- (void)testThatUpdatingVerificationHandlerSetsNewHandler
{
    id<MCKVerificationHandler> handler = [[MCKDefaultVerificationHandler alloc] init];
    
    verification.setVerificationHandler(handler);
    
    expect(verification.verificationHandler).to.equal(handler);
}

- (void)testThatUpdatingVerificationHandlerTwiceThrowsAPIMisuse
{
    verification.setVerificationHandler([[MCKDefaultVerificationHandler alloc] init]);
    
    expect(^{
        verification.setVerificationHandler([[MCKDefaultVerificationHandler alloc] init]);
    }).to.raise(MCKAPIMisuseException);
}

- (void)testThatUpdatingVerificationHandlerWithNilValueThrowsAPIMisuse
{
    expect(^{
        verification.setVerificationHandler(nil);
    }).to.raise(MCKAPIMisuseException);
}

- (void)testThatUpdatingTimeoutSetsNewTimeout
{
    verification.setTimeout(1.0);
    
    expect(verification.timeout).to.equal(1.0);
}

- (void)testThatUpdatingTimeoutTwiceThrowsAPIMisuse
{
    verification.setTimeout(1.0);
    
    expect(^{
        verification.setTimeout(2.0);
    }).to.raise(MCKAPIMisuseException);
}

@end
