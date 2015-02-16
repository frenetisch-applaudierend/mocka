//
//  MCKVerificationTest.m
//  mocka
//
//  Created by Markus Gasser on 28.03.14.
//  Copyright (c) 2014 konoma GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MCKVerification.h"
#import "MCKMockingContext.h"
#import "MCKInvocationRecorder.h"
#import "MCKInvocationVerifier.h"
#import "MCKDefaultVerificationHandler.h"
#import "MCKAPIMisuse.h"


@interface MCKVerificationTest : XCTestCase @end
@implementation MCKVerificationTest {
    MCKVerification *verification;
    MCKMockingContext *context;
}

#pragma mark - Setup

- (void)setUp
{
    context = [[MCKMockingContext alloc] init];
    context.invocationVerifier = MKTMock([MCKInvocationVerifier class]);
    
    verification = [[MCKVerification alloc] initWithMockingContext:context location:nil verificationBlock:nil];
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


#pragma mark - Test Execution

- (void)testThatExecuteCallsVerificationBlock
{
    __block BOOL wasCalled = NO;
    MCKVerification *v = [[MCKVerification alloc] initWithMockingContext:context location:nil verificationBlock:^{
        wasCalled = YES;
    }];
    
    [v execute];
    
    expect(wasCalled).to.beTruthy();
}

- (void)testThatExecuteSetsContextModeToVerifiyingDuringCall
{
    __block MCKContextMode contextMode;
    MCKVerification *v = [[MCKVerification alloc] initWithMockingContext:context location:nil verificationBlock:^{
        contextMode = [context mode];
    }];
    [context updateContextMode:MCKContextModeRecording];
    
    [v execute];
    
    expect(contextMode).to.equal(MCKContextModeVerifying);
}

- (void)testThatExecuteSetsContextModeToRecordingAfterCall
{
    [context updateContextMode:MCKContextModeVerifying];
    
    [verification execute];
    
    expect(context.mode).to.equal(MCKContextModeRecording);
}

- (void)testThatExecuteWithMultipleVerificationsThrowsAPIMisuse {
    NSInvocation *invocation = [NSInvocation invocationForTarget:self selectorAndArguments:@selector(self)];
    MCKInvocationPrototype *prototype = [[MCKInvocationPrototype alloc] initWithInvocation:invocation];
    MCKInvocationRecorder *recorder = MKTMock([MCKInvocationRecorder class]);
    
    __block __weak MCKVerification *weakV;
    MCKVerification *v = [[MCKVerification alloc] initWithMockingContext:context location:nil verificationBlock:^{
        [weakV verifyPrototype:prototype inInvocationRecorder:recorder];
        [weakV verifyPrototype:prototype inInvocationRecorder:recorder];
    }];
    weakV = v;
    
    [context updateContextMode:MCKContextModeVerifying];
    expect(^{
        [v execute];
    }).to.raise(MCKAPIMisuseException);
    
}


#pragma mark - Test Handling Invocation Prototypes

- (void)testThatVerifyingPrototypeVerifiesUsingHandler
{
    id<MCKVerificationHandler> handler = MKTMockProtocol(@protocol(MCKVerificationHandler));
    MCKInvocationPrototype *prototype = MKTMock([MCKInvocationPrototype class]);
    MCKInvocationRecorder *recorder = MKTMock([MCKInvocationRecorder class]);
    
    NSArray *invocations = @[ @"dummy1", @"dummy2" ];
    [MKTGiven([recorder recordedInvocations]) willReturn:invocations];
    
    
    verification.setVerificationHandler(handler);
    
    [verification verifyPrototype:prototype inInvocationRecorder:recorder];
    
    [(id<MCKVerificationHandler>)MKTVerify(handler) verifyInvocations:invocations forPrototype:prototype];
}

@end
