//
//  RGMockVerificationHandler.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockContext.h"
#import "RGMockInvocationRecorder.h"


@protocol RGMockVerificationHandler <NSObject>

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
            withNonObjectArgumentMatchers:(NSArray *)matchers
                     inInvocationRecorder:(RGMockInvocationRecorder *)recorder
                                satisfied:(BOOL *)satisified
                           failureMessage:(NSString **)failureMessage;

@end


// Setting a verification handler
#define mck_setVerificationHandler(handler) if (mck_setVerificationHandlerOnContext(mck_currentContext(), (handler)))

static BOOL mck_setVerificationHandlerOnContext(RGMockContext *context, id<RGMockVerificationHandler> handler) {
    [context setVerificationHandler:handler];
    return YES;
}
