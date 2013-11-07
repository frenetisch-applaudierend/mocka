//
//  MCKVerification.m
//  mocka
//
//  Created by Markus Gasser on 7.11.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKVerificationSyntax.h"
#import "MCKMockingContext.h"
#import "MCKMockingContext+MCKVerification.h"


void _mck_beginVerification(id testCase, MCKLocation *loc, id<MCKVerificationResultCollector> coll, void(^calls)(void)) {
    NSCParameterAssert(calls != nil);
    
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    context.currentLocation = loc;
    
    [context beginVerificationWithTimeout:0.0];
    
    if (coll != nil) {
        [context.invocationVerifier startGroupVerificationWithCollector:coll];
        calls();
        [context.invocationVerifier finishGroupVerification];
    } else {
        calls();
    }
}

void _mck_setVerificationTimeout(id testCase, NSTimeInterval timeout) {
    MCKMockingContext *context = [MCKMockingContext contextForTestCase:testCase];
    context.invocationVerifier.timeout = timeout;
}
