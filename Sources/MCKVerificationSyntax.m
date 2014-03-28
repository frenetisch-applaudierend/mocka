//
//  MCKVerification.m
//  mocka
//
//  Created by Markus Gasser on 7.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKVerificationSyntax.h"
#import "MCKMockingContext.h"
#import "MCKInvocationVerifier.h"
#import "MCKAllCollector.h"


@interface MCKVerifyBlockRecorder ()

+ (instancetype)recorderWithContext:(MCKMockingContext *)context collector:(id<MCKVerificationResultCollector>)collector;

@property (nonatomic, readonly) MCKMockingContext *mockingContext;
@property (nonatomic, readonly) id<MCKVerificationResultCollector> collector;

@end


MCKVerifyBlockRecorder* _mck_verify_call(MCKLocation *loc, id<MCKVerificationResultCollector> coll) {
    MCKMockingContext *context = [MCKMockingContext currentContext];
    context.currentLocation = loc;
    return [MCKVerifyBlockRecorder recorderWithContext:context collector:(coll ?: [[MCKAllCollector alloc] init])];
}

void _mck_setVerificationTimeout(NSTimeInterval timeout) {
    MCKMockingContext *context = [MCKMockingContext currentContext];
    context.invocationVerifier.timeout = timeout;
}

MCKVerificationRecorder* _MCKRecorder(void)
{
    return [[MCKVerificationRecorder alloc] initWithMockingContext:[MCKMockingContext currentContext]];
}

MCKVerification* _MCKVerification(MCKLocation *location, MCKVerificationBlock block)
{
    return [[MCKVerification alloc] initWithMockingContext:[MCKMockingContext currentContext] location:location verificationBlock:block];
}


@implementation MCKVerifyBlockRecorder

+ (instancetype)recorderWithContext:(MCKMockingContext *)context collector:(id<MCKVerificationResultCollector>)collector {
    return [[self alloc] initWithContext:context collector:collector];
}

- (instancetype)initWithContext:(MCKMockingContext *)context collector:(id<MCKVerificationResultCollector>)collector {
    if ((self = [super init])) {
        _mockingContext = context;
        _collector = collector;
    }
    return self;
}

- (void)setVerifyCallBlock:(void (^)(void))calls {
    [self.mockingContext verifyCalls:calls usingCollector:self.collector];
}

@end
