//
//  MCKVerificationTest.m
//  mocka
//
//  Created by Markus Gasser on 25.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockito/OCMockito.h>

#import "MCKVerificationRecorder.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKInvocationVerifier.h"
#import "MCKAPIMisuse.h"


@interface MCKVerificationRecorderTest : XCTestCase @end
@implementation MCKVerificationRecorderTest {
    MCKVerificationRecorder *verification;
    MCKMockingContext *context;
}

#pragma mark - Setup

- (void)setUp
{
    context = [[MCKMockingContext alloc] initWithTestCase:self];
    verification = [[MCKVerificationRecorder alloc] initWithMockingContext:context];
    
    context.invocationVerifier = MKTMock([MCKInvocationVerifier class]);
}


#pragma mark - Test Default Values

- (void)testThatInitiallyNoVerificationBlockIsSet
{
    expect(verification.verificationBlock).to.beNil();
}

- (void)testThatInitiallyTheDefaultHandlerIsSet
{
    expect(verification.verificationHandler).to.beKindOf([MCKDefaultVerificationHandler class]);
}

- (void)testThatInitiallyNoTimeoutIsSet
{
    expect(verification.timeout).to.beNil();
}


#pragma mark - Test Updating Values

- (void)testThatUpdatingVerificationBlockSetsNewBlock
{
    MCKVerificationBlock block = ^{};
    
    verification.setVerificationBlock(block);
    
    expect(verification.verificationBlock).to.equal(block);
}

- (void)testThatUpdatingVerificationBlockTwiceThrowsAPIMisuse
{
    verification.setVerificationBlock(^{});
    
    expect(^{
        verification.setVerificationBlock(^{});
    }).to.raise(MCKAPIMisuseException);
}

- (void)testThatUpdatingVerificationBlockWithNilValueThrowsAPIMisuse
{
    expect(^{
        verification.setVerificationBlock(nil);
    }).to.raise(MCKAPIMisuseException);
}

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
    verification.setTimeout(@1.0);
    
    expect(verification.timeout).to.equal(@1.0);
}

- (void)testThatUpdatingTimeoutTwiceThrowsAPIMisuse
{
    verification.setTimeout(@1.0);
    
    expect(^{
        verification.setTimeout(@2.0);
    }).to.raise(MCKAPIMisuseException);
}


#pragma mark - Test Verification

- (void)testThatVerificationIsExecutedAfterConfigurationIsDone
{
    MCKVerificationBlock block = ^{};
    id<MCKVerificationHandler> handler = [[MCKDefaultVerificationHandler alloc] init];
    
    [[MCKVerificationRecorder alloc] initWithMockingContext:context]
    .setVerificationBlock(block)
    .setVerificationHandler(handler)
    .setTimeout(@10.0);
    
    [MKTVerify(context.invocationVerifier) executeVerificationWithBlock:block handler:handler timeout:10.0];
}

@end
