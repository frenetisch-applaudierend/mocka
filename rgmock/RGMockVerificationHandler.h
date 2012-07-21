//
//  RGMockVerificationHandler.h
//  rgmock
//
//  Created by Markus Gasser on 14.07.12.
//  Copyright (c) 2012 coresystems ag. All rights reserved.
//

#import "RGMockContext.h"


@protocol RGMockVerificationHandler <NSObject>

- (NSIndexSet *)indexesMatchingInvocation:(NSInvocation *)prototype
                    inRecordedInvocations:(NSArray *)recordedInvocations
                                satisfied:(BOOL *)satisified;

@end


// Setting a verification handler
#define mock_set_verification_handler(handler) if (mock_set_verification_handler_on_context(mock_currentContext(), (handler)))
static BOOL mock_set_verification_handler_on_context(RGMockContext *context, id<RGMockVerificationHandler> handler) {
    [context setVerificationHandler:handler];
    return YES;
}
