//
//  MCKVerificationResultCollector.m
//  mocka
//
//  Created by Markus Gasser on 30.9.2013.
//  Copyright (c) 2013 konoma GmbH. All rights reserved.
//

#import "MCKVerificationResultCollector.h"

#import "MCKMockingContext.h"
#import "MCKInvocationVerifier.h"

#import <objc/runtime.h>


void _mck_setVerifyGroupCollector(id<MCKVerificationResultCollector> collector) {
    MCKMockingContext *context = [MCKMockingContext currentContext];
    [context.invocationVerifier startGroupVerificationWithCollector:collector];
}

BOOL _mck_executeGroupCalls(id testCase) {
    static const NSUInteger ExecutingKey;
    
    id executingMarker = objc_getAssociatedObject(testCase, &ExecutingKey);
    if (executingMarker == nil) {
        objc_setAssociatedObject(testCase, &ExecutingKey, @YES, OBJC_ASSOCIATION_COPY);
        return YES;
    } else {
        MCKMockingContext *context = [MCKMockingContext currentContext];
        [context.invocationVerifier finishGroupVerification];
        objc_setAssociatedObject(testCase, &ExecutingKey, nil, OBJC_ASSOCIATION_COPY);
        return NO;
    }
}
